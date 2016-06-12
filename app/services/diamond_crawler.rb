class DiamondCrawler
  def initialize
    @parser = DiamondComicsParser.new
    @db_saver = DBSaver.new
    @logger = Logger.new "#{Rails.root}/log/diamond_crawler.log"
  end

  def test_process(count = nil, go_anyway = false)
    log '---------------------------------'
    log 'DiamondCrawler started'
    new_releases = current_week_releases
    date = wednesday_date new_releases
    log "Listed date is #{date}"
    if wl = check_for_weekly_list_in_db(date)
      if !go_anyway && wl.list == new_releases
        log 'List wasnt updated, finishing process'
        return
      else
        log "List was updated"
        wl.update_column :list, new_releases
      end
    else
      WeeklyList.create list: new_releases, wednesday_date: date
      log "Created new WeeklyList"
    end
    diamond_ids = comics_diamond_ids new_releases 
    count ||= diamond_ids.size
    log 'Starting crawling process'
    scrape_data diamond_ids.first(count)
    log 'Finished crawling process'
  rescue => e
    log "Something went wrong :( . Error message: #{e.message}"
  end

  private

  def log(message)
    @logger.info message
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
    diamond_ids.each do |diamond_id|
      comic_page = @parser.get_comic_page diamond_id
      comic = @parser.parse_comic_info comic_page
      log pretty_comic_log_message(comic)
      @db_saver.persist_to_db comic
    end
  end
end
