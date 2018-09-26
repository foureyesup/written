class Result < ApplicationRecord
  belongs_to :search
  belongs_to :user
  
  after_commit :test_result, :on => :create
  
  def test_result
    search = Search.find(self.search_id)
    user = User.find(self.user_id)
    start_date = search.start_date
    #make sure this page isn't really old by checking last crawled date
    if self.test_crawl_age(start_date)
      puts "rejected by test_crawl_age"
      self.complete_processing("rejected by test_crawl_age")
    # is there an author?
    elsif self.estimated_author.present?
      #does the author match the user name?
      if self.author_matches_user(user.name)
        #is there a date?
        if self.estimated_published_date.present?
          #does the date match?
          if self.test_webhose_date_match(start_date)
            puts "full result match!"
            self.create_story_from_result(self.estimated_published_date)
            self.complete_processing("complete")
            #check whether this is the last result and if it was, tell search to test whether more searching is needed
            self.check_if_last_result
          end
        #if there's no date (e.g. from webhose, try to get it from pismo)
        elsif
          puts "couldn't determine date, sending to pismo"
          self.pismo_check
        end
      else
        self.complete_processing("rejected by author_matches_user")
      end
    else
      #if there's no author, try to get it from pismo
      puts "couldn't determine author, sending to pismo"
      self.pismo_check
    end
  end
  
  def pismo_check
    begin
      search = Search.find(self.search_id)
      doc = Pismo::Document.new(self.url)
      author = doc.author.present? ? doc.author : nil
      start_date = search.start_date
      date = self.estimated_published_date.present? ? self.estimated_published_date : nil
      if author.present? && date.present?
        if doc.author.downcase == user.name.downcase && date > start_date
          puts "pismo matched author with webhose date!"
          self.create_story_from_result(date)
          self.complete_processing("complete")
          #check whether this is the last result and if it was, tell search to test whether more searching is needed
          self.check_if_last_result
        end
      else
        #if not, offload to aylien as a thread-safe background job
        puts "no pismo author or date match, offloading to aylien"
        self.update_attribute(:processing_status, "sent to aylien")
        AylienProcessorWorker.perform_async(self.id, self.estimated_author.present? ? self.estimated_author : author, date)
      end
    rescue OpenURI::HTTPError => e
      the_status = e.io.status[0] # => 3xx, 4xx, or 5xx
      puts "Whoops got a bad status code #{e.message}"
    end
  end
  
  def test_crawl_age(start_date)
    self.date_last_crawled < start_date ? true : false
  end
  
  def author_matches_user(user_name)
    self.estimated_author.downcase == user_name.downcase ? true : false
  end
  
  def test_webhose_date_match(start_date)
    self.estimated_published_date > start_date ? true : false
  end
  
  def complete_processing(status)
    self.update_attribute(:processing_status, status)
    self.update_attribute(:processed_date, Time.now)
  end
  
  def create_story_from_result(date_published)
    Story.create!(
      story_url: self.url,
      title: self.title,
      lede: self.snippet,
      date_published: date_published,
      user_id: self.user_id,
      publication_id: self.publication_id,
      result_id: self.id,
      search_id: self.search.id      
    )
  end
  
  def check_if_last_result
    search = self.search
    if search.results.where(processed_date: nil).count == 0
      search.test_if_search_needs_a_bing_search
    else
      puts "not the last result yet!"
    end
  end
  
end
