class Result < ApplicationRecord
  belongs_to :search
  
  def test_result(search_id)
    search = Search.find(search_id)
    user = User.find(self.user_id)
    start_date = search.start_date
    #make sure this page isn't really old by checking last crawled date from bing
    if self.date_last_crawled < start_date
      self.update_attribute(:processing_status, "complete")
      self.update_attribute(:processed_date, Time.now)
    else
      doc = Pismo::Document.new(self.url)
      author = doc.author
      date = doc.datetime
      #test if pismo can make an accurate match
      if doc.author.downcase == user.name.downcase && date > start_date
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
      else
        #if not, offload to aylien as a thread-safe background job
        self.update_attribute(:processing_status, "in progress")
      end
    end
  end
  
end
