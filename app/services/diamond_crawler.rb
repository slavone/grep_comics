class DiamondCrawler
  def initialize
    @parser = DiamondComicsParser.new
    @db_saver = nil
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
    log "Scraped #{diamond_ids_count} diamond_ids. Creating sidekiq tasks for #{options[:count]}/#{diamond_ids_count} of them"
    diamond_ids.first(options[:count]).each do |diamond_id|
      ComicScraper.perform_async diamond_id, @weekly_list.id
    end
  rescue => e
    log "Something went wrong :( . Error message: #{e.message}", :error
  end

  def test_process(count = nil, go_anyway = false, not_current_week_list = nil)
    log '---------------------------------'
    log 'DiamondCrawler started'
    new_releases = if not_current_week_list
                     @parser.get_page not_current_week_list
                   else
                     current_week_releases
                   end
    date = wednesday_date new_releases
    log "Listed date is #{date}"
    if wl = check_for_weekly_list_in_db(date)
      if !go_anyway && wl.list == new_releases
        log 'List wasnt updated, finishing process'
        return
      else
        log "List was updated"
        wl.update_column :list, new_releases
        initialize_db_saver(wl)
      end
    else
      wl = WeeklyList.create list: new_releases, wednesday_date: date
      initialize_db_saver(wl)
      log "Created new WeeklyList"
    end
    diamond_ids = comics_diamond_ids new_releases
    count ||= diamond_ids.size
    log 'Starting crawling process'
    scrape_data diamond_ids.first(count)
    log 'Finished crawling process'
  rescue => e
    log "Something went wrong :( . Error message: #{e.message}", :error
  end

  private

  def log(message, msg_type = :info)
    @logger.send(msg_type, message) unless Rails.env == 'test'
  end

  def initialize_db_saver(weekly_list)
    @db_saver = DBSaver.new(weekly_list)
  end

  def pretty_comic_log_message(comic)
    comic.select { |k, _| k != :preview }.map { |_, v| v }.join('|')
  end

  def current_week_releases
    @parser.get_page DiamondComicsParser::CURRENT_WEEK
  end

  def check_for_weekly_list_in_db(date)
    WeeklyList.find_by wednesday_date: date
  end

  def wednesday_date(page)
    @parser.parse_wednesday_date(page)
  end

  def comics_diamond_ids(page)
    @parser.parse_diamond_codes(page, :comics)
  end

  def scrape_data(diamond_ids)
    log 'DBSaver wasnt initialized', :error unless @db_saver
    diamond_ids.each do |diamond_id|
      comic_page = @parser.get_comic_page diamond_id
      if @parser.page_found? comic_page
        comic = @parser.parse_comic_info comic_page
        log pretty_comic_log_message(comic)
        @db_saver.persist_to_db comic
      end
    end
  end
end
