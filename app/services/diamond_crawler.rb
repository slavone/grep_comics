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
    listed_date = listed_date(releases_page)
    log "Listed date is #{listed_date}"
    return unless set_weekly_list!(listed_date, releases_page, options)

    diamond_ids = comics_diamond_ids releases_page
    diamond_ids_count = diamond_ids.size
    options[:count] ||= diamond_ids_count
    log diamond_ids.inspect

    log "Scraped #{diamond_ids_count} diamond_ids. Creating sidekiq tasks for #{options[:count]}/#{diamond_ids_count} of them"
    diamond_ids.first(options[:count]).each do |diamond_id|
      ComicScraper.perform_async :create, diamond_id, @weekly_list.id
    end
  rescue => e
    log "Something went wrong :( . Error message: #{e.message}", :error
  end

  def retry_for_updates(weekly_list)
    log '---------------------------------'
    log 'DiamondCrawler retrying for updates started'

    weekly_list.comics_with_no_covers.each do |comic|
      ComicScraper.perform_async :update, comic.diamond_code, weekly_list.id
    end
  end

  private

  def set_weekly_list!(wednesday_date, releases_page, options = {})
    if @weekly_list = WeeklyList.find_by(wednesday_date: wednesday_date)
      if !options[:overwrite] && @weekly_list.list == releases_page
        log 'list wasnt updated, finishing process'
        return
      else
        log "list was updated"
        @weekly_list.update(list: releases_page)
        @weekly_list
      end
    else
      @weekly_list = WeeklyList.create list: releases_page, wednesday_date: wednesday_date
    end
  end

  def log(message, msg_type = :info)
    @logger.send(msg_type, message) unless Rails.env == 'test'
  end

  def current_week_releases
    @parser.get_page DiamondComicsParser::CURRENT_WEEK
  end

  def listed_date(page)
    @parser.parse_wednesday_date(page)
  end

  def comics_diamond_ids(page)
    @parser.parse_diamond_codes(page, :comics)
  end
end
