class ComicScraper
  include Sidekiq::Worker
  sidekiq_options queue: 'comic_scraper_workers'

  def initialize
    @logger = Logger.new "#{Rails.root}/log/diamond_crawler.log"
    @parser = DiamondComicsParser.new
  end

  def perform(diamond_id, weekly_list_id)
    db_saver = DBSaver.new weekly_list_id
    comic_page = @parser.get_comic_page diamond_id
    if @parser.page_found? comic_page
      comic = @parser.parse_comic_info comic_page
      log pretty_comic_log_message(comic)
      db_saver.persist_to_db comic
    else
      log "No page was found for comic with id #{diamond_id}"
    end
  end

  private

  def log(message, msg_type = :info)
    @logger.send(msg_type, message) unless Rails.env == 'test'
  end

  def pretty_comic_log_message(comic)
    comic.select { |k, _| k != :preview }.map { |_, v| v }.join('|')
  end
end
