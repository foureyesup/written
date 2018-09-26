class Search < ApplicationRecord
  
  has_many :results
  belongs_to :user
  has_many :stories
  
  #after_create :fetch_results_by_bing_search
  after_create :fetch_webhose_results
  
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
    timestamp = self.start_date.to_datetime.strftime('%Q')
    search_url = self.search_url
    search_name = self.search_name
    query = %Q[site:#{search_url} (author:"#{search_name}" OR text:"#{search_name}")]
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
      self.update_attribute(:status, "webhose completed")
      self.update_attribute(:date_executed, Time.now)
    else
      self.update_attribute(:status, "sent to bing")
      self.fetch_results_by_bing_search
    end
  end
  
  def fetch_results_by_bing_search
    account_key = "af9cfc9cc71345a7922c06aac7dc8639"
    search_url = self.search_url
    search_name = self.search_name
    query = %Q[site:#{search_url} "#{search_name}"]
    bing = CognitiveBing.new(account_key, :count => 30)
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
      self.update_attribute(:status, "bing completed")
      self.update_attribute(:date_executed, Time.now)
    else
      self.update_attribute(:status, "failed - no bing results")
      self.update_attribute(:date_executed, Time.now)
    end
  end
  
  def fetch_stories_by_bing_news
    bing = CognitiveBingNews.new(account_key)
    result_set = bing.search(search_term)
  end
  
  def test_all_search_results
    self.results.where(processed_date: nil).each do |r|
      r.test_result
    end
  end
  
  def test_if_search_has_stories
    if self.stories.count != 0
      true
    else
      false
    end
  end
  
  def test_if_search_needs_a_bing_search
    unless self.test_if_search_has_stories
      if self.status == "webhose completed"
        self.update_attribute(:status, "sent to bing")
        self.fetch_results_by_bing_search
        true
      elsif self.status == "bing completed"
        puts "no more stories to be found :("
        self.update_attribute(:status, "completed")
        false
      end
    end
  end
  
end
