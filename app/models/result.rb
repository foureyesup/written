class Result < ApplicationRecord
  belongs_to :search
  belongs_to :user
  
  def test_result
    search = Search.find(self.search_id)
    user = User.find(self.user_id)
    start_date = search.start_date
    #make sure this page isn't really old by checking last crawled date
    if self.date_last_crawled < start_date
      puts "article too old"
      self.update_attribute(:processing_status, "complete")
      self.update_attribute(:processed_date, Time.now)
    elsif self.estimated_author.present? && self.estimated_author.downcase != user.name.downcase
      puts "webhose author conflict"
      self.update_attribute(:processing_status, "complete")
      self.update_attribute(:processed_date, Time.now)
    elsif self.estimated_published_date > start_date && self.estimated_author.downcase == user.name.downcase
      puts "full result match!"
      Story.create!(
        story_url: self.url,
        title: self.title,
        lede: self.snippet,
        date_published: self.estimated_published_date,
        user_id: user.id,
        publication_id: self.publication_id,
        result_id: self.id      
      )
      self.update_attribute(:processing_status, "complete")
      self.update_attribute(:processed_date, Time.now)
    else
      begin
        doc = Pismo::Document.new(self.url)
        author = doc.author
        date = doc.datetime
        if author.present? && date.present?
          #test if pismo can make an accurate match
          if doc.author.downcase == user.name.downcase && self.estimated_published_date > start_date
            puts "pismo matched!"
            Story.create!(
              story_url: self.url,
              title: self.title,
              lede: self.snippet,
              date_published: doc.datetime,
              user_id: user.id,
              publication_id: self.publication_id,
              result_id: self.id      
            )
            self.update_attribute(:processing_status, "complete")
            self.update_attribute(:processed_date, Time.now)
          end
        else
          #if not, offload to aylien as a thread-safe background job
          puts "no pismo match, offloading to aylien"
          self.update_attribute(:processing_status, "in progress")
          AylienProcessorWorker.perform_async(self.id, self.estimated_author, self.estimated_published_date)
        end
      rescue OpenURI::HTTPError => e
        the_status = e.io.status[0] # => 3xx, 4xx, or 5xx
        puts "Whoops got a bad status code #{e.message}"
      end
    end
  end
  
end
