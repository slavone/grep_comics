class DiamondWeeklyExecutor
  def initialize
    @parser = DiamondComicsParser.new
  end

  def look_through_new_releases
    new_releases = @parser.get_page DiamondComicsParser::CURRENT_WEEK
    wednesday = @parser.parse_wednesday_date(new_releases)
    diamond_ids = @parser.parse_diamond_codes(new_releases, :comics)
  end

  def traverse_ids(diamond_ids)
    diamond_ids.each do |diamond_id|
      comic_page = @parser.get_comic_page diamond_id
      comic = @parser.parse_comic_info comic_page
      unless Comic.find_by title: comic[:title]
        publisher = if p = Publisher.find_by(name: comic[:publisher])
                      p
                    else
                      Publisher.create name: comic[:publisher]
                    end
        Comic.create map_to_model_params(comic).merge({publisher: publisher})
      end
    end
  end

  def map_to_model_params(comic)
    { diamond_code: comic[:diamond_id], title: comic[:title],
      issue_number: comic[:issue_number], preview: comic[:preview],
      suggested_price: comic[:suggested_price].to_f, item_type: comic[:type],
      shipping_date: comic[:shipping_date]
    }
  end

  def test_process(count = nil)
    diamond_ids = look_through_new_releases
    count ||= diamond_ids.size
    traverse_ids(diamond_ids.first(count))
  end

end
