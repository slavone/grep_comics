class DiamondCrawler
  def initialize
    @parser = DiamondComicsParser.new
    @db_saver = DBSaver.new
  end

  #get current week list
  #check with the stored list
  #if different => check date
  #if different date => create new week list object
  #log shit

  def test_process(count = nil)
    diamond_ids = look_through_new_releases
    count ||= diamond_ids.size
    traverse_ids(diamond_ids.first(count))
  end

  private

  def look_through_new_releases
    new_releases = @parser.get_page DiamondComicsParser::CURRENT_WEEK
    wednesday = @parser.parse_wednesday_date(new_releases)
    diamond_ids = @parser.parse_diamond_codes(new_releases, :comics)
  end

  def traverse_ids(diamond_ids)
    diamond_ids.each do |diamond_id|
      comic_page = @parser.get_comic_page diamond_id
      comic = @parser.parse_comic_info comic_page
      @db_saver.persist_to_db comic
    end
  end

end
