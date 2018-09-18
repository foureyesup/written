class Search < ApplicationRecord
  
  has_many :results
  belongs_to :user
  
  #after_create :fetch_results_by_bing_search
  after_create :fetch_webhose_results
  
  def process_search_results
    self.results.where(processed_date: nil).each do |r|
      r.test_result
    end
  end
  
  def fetch_api_results
    url = 'https://newsapi.org/v2/everything?'\
          'q=melinda healy&'\
          'sources=google-news&'\
          'apiKey=639e9cb895cb4e049a5a9fe0a7c76b2d'
    req = open(url)
    response_body = req.read
    hash = JSON.parse response_body
    hash["posts"].count
  end
  
  def fetch_webhose_results
    query = self.query
    timestamp = self.start_date.to_datetime.strftime('%Q')
    url = 'http://webhose.io/filterWebContent?'\
          'token=e9e829b1-ae22-40b8-8a19-ea4b9fa79894&'\
          'format=json&'\
          'sort=crawled&'\
          'ts=' + timestamp + '&'\
          'q=' + URI.encode(query)
    req = open(url)
    response_body = req.read
    hash = JSON.parse response_body
    if hash["posts"].present?
      hash["posts"].each do |s|
        r = Result.create!(
          url: s["url"],
          date_last_crawled: s["crawled"],
          title: s["title"],
          user_id: self.user_id,
          publication_id: self.publication_id,
          search_id: self.id,
          estimated_published_date: s["published"],
          estimated_author: s["author"]
        )   
      end
    end
    self.update_attribute(:date_executed, Time.now)
  end
  
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
