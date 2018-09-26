class AylienProcessorWorker
  include Sidekiq::Worker

  def perform(id, result_author, result_date)
    result = Result.find(id)
    url = result.url
    user = User.find(result.user_id)
    start_date = result.search.start_date
    client = AylienTextApi::Client.new
    response = client.extract url: url
    date = response[:publishDate]
    author = response[:author]
    if author.present? && date.present?
      if author.downcase == user.name.downcase && date > start_date
        puts "full aylien match!"
        Story.create!(
          story_url: result.url,
          title: result.title,
          lede: result.snippet,
          date_published: date,
          user_id: user.id,
          publication_id: result.publication_id,
          result_id: result.id      
        )
        result.update_attribute(:processing_status, "complete")
        result.update_attribute(:processed_date, Time.now)
        result.check_if_last_result
      else
        puts "aylien didn't match, we're done here"
        result.update_attribute(:processing_status, "complete")
        result.update_attribute(:processed_date, Time.now)
        result.check_if_last_result
      end
    elsif author.present? && result_date.present?
      if author.downcase == user.name.downcase && result_date > start_date
        puts "partial aylien match on author!"
        Story.create!(
          story_url: result.url,
          title: result.title,
          lede: result.snippet,
          date_published: result_date,
          user_id: user.id,
          publication_id: result.publication_id,
          result_id: result.id      
        )
        result.update_attribute(:processing_status, "complete")
        result.update_attribute(:processed_date, Time.now)
        result.check_if_last_result
      else
        puts "aylien author and webhose date didn't match, we're done here"
        result.update_attribute(:processing_status, "complete")
        result.update_attribute(:processed_date, Time.now)
        result.check_if_last_result
      end
    elsif result_author.present? && date.present?
      if result_author.downcase == user.name.downcase && date > start_date
        puts "partial aylien match on date!"
        Story.create!(
          story_url: result.url,
          title: result.title,
          lede: result.snippet,
          date_published: date,
          user_id: user.id,
          publication_id: result.publication_id,
          result_id: result.id,
          search_id: result.search.id        
        )
        result.update_attribute(:processing_status, "complete")
        result.update_attribute(:processed_date, Time.now)
        result.check_if_last_result
      else
        puts "aylien date and webhose author didn't match, we're done here"
        result.update_attribute(:processing_status, "complete")
        result.update_attribute(:processed_date, Time.now)
        result.check_if_last_result
      end
    else
      puts "not doing regexp search for now"
      #puts "no aylien match, doing basic regexp search"
      #doc = Nokogiri::HTML(open(result.url))
      #if doc.search('*').text_matches(/#{user.name}/i).count != 0
      #  puts "regexp match!"
      #  Story.create!(
      #    story_url: result.url,
      #    title: result.title,
      #    lede: result.snippet,
      #    date_published: result.date_last_crawled,
      #    user_id: user.id,
      #    publication_id: result.publication_id,
      #    result_id: result.id,
      #    search_id: result.search.id        
      #  )
      #  result.update_attribute(:processing_status, "complete")
      #  result.update_attribute(:processed_date, Time.now)
      #  if result.check_if_last_result
      #    result.search.test_if_search_needs_a_bing_search
      #  end
      puts "no match found"
      result.update_attribute(:processing_status, "complete")
      result.update_attribute(:processed_date, Time.now)
      result.check_if_last_result
    end
  end
  
end
