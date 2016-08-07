class DiamondCrawler
  def initialize
    @parser = DiamondComicsParser.new
    @logger = Logger.new "#{Rails.root}/log/diamond_crawler.log"
  end

  def test_cron
    log 'Hey its cron'
  end

  def start_process(list_url, options = {})
    log '---------------------------------'
    log 'DiamondCrawler started'
    releases_page = @parser.get_page list_url
    listed_date = @parser.parse_wednesday_date(releases_page)
    log "Listed date is #{listed_date}"
    if @weekly_list = WeeklyList.find_by(wednesday_date: listed_date)
      if !options[:overwrite] && @weekly_list.list == releases_page
        log 'List wasnt updated, finishing process'
        return
      else
        log "List was updated"
        @weekly_list.update list: releases_page
      end
    else
      @weekly_list = WeeklyList.create list: releases_page, wednesday_date: listed_date
    end
    diamond_ids = comics_diamond_ids releases_page
    diamond_ids_count = diamond_ids.size
    options[:count] ||= diamond_ids_count
    log diamond_ids.inspect
    log "Scraped #{diamond_ids_count} diamond_ids. Creating sidekiq tasks for #{options[:count]}/#{diamond_ids_count} of them"
    diamond_ids.first(options[:count]).each do |diamond_id|
      ComicScraper.perform_async diamond_id, @weekly_list.id
    end
  rescue => e
    log "Something went wrong :( . Error message: #{e.message}", :error
  end

  private

  def log(message, msg_type = :info)
    @logger.send(msg_type, message) unless Rails.env == 'test'
  end

  def current_week_releases
    @parser.get_page DiamondComicsParser::CURRENT_WEEK
  end

  def comics_diamond_ids(page)
    @parser.parse_diamond_codes(page, :comics)
  end
end
