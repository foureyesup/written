class Search < ApplicationRecord
  
  has_many :results
  
  after_create :fetch_results_by_bing_search
  
  def fetch_results_by_bing_search
    account_key = "af9cfc9cc71345a7922c06aac7dc8639"
    query = self.query
    bing = CognitiveBing.new(account_key)
    result_set = bing.search(query)
    puts result_set
    if result_set[:webPages]
      result_set[:webPages][:value].each do |s|
        r = Result.create!(
        url: s[:url],
        display_url: s[:displayUrl],
        date_last_crawled: s[:dateLastCrawled],
        snippet: s[:snippet],
        language: s[:language],
        title: s[:name],
        user_id: self.user_id,
        publication_id: self.publication_id,
        search_id: self.id
        )      
      end
    end
    self.update_attribute(:date_executed, Time.now)
  end
  
  def fetch_stories_by_bing_news
    bing = CognitiveBingNews.new(account_key)
    result_set = bing.search(search_term)
  end
  
end
