class DiamondCrawler
  def initialize
    @parser = DiamondComicsParser.new
    @db_saver = DBSaver.new
  end

  def test_process(count = nil, go_anyway = false)
    new_releases = current_week_releases
    date = wednesday_date new_releases
    if wl = check_for_weekly_list_in_db(date)
      if !go_anyway && wl.list == new_releases
        puts '--------------'
        puts 'Nothing changed, process finished'
        puts '--------------'
        return
      else
        puts '--------------'
        puts 'Updated current weekly_list'
        puts '--------------'
        wl.update_column :list, new_releases
      end
    else
      WeeklyList.create list: new_releases, wednesday_date: date
    end
    diamond_ids = comics_diamond_ids new_releases 
    count ||= diamond_ids.size
    puts '--------------'
    puts 'Started crawling'
    collect_info_for diamond_ids.first(count)
    puts 'Finished crawling'
    puts '--------------'
  end

  private

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

  def collect_info_for(diamond_ids)
    diamond_ids.each do |diamond_id|
      comic_page = @parser.get_comic_page diamond_id
      comic = @parser.parse_comic_info comic_page
      @db_saver.persist_to_db comic
    end
  end
end
