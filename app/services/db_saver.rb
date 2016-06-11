class DBSaver
  def persist_to_db(comic_hash)
    unless Comic.find_by diamond_code: comic_hash[:diamond_id]
      #TODO more strict search, single issues with variant covers
      #diamond_code && title != cur_title && issue_number != issue_number
      comic_params = map_params_to_model(comic_hash)
      publisher = build_publisher comic_hash
      creators = build_creators comic_hash[:creators]
      comic_params.merge!(publisher: publisher).merge! creators
      Comic.create comic_params
    end
  end

  private

  def build_creators(creators_hash)
    #TODO variant_covers
    creators = {}

    creators_hash.each do |creator_type, arr_of_creators|
      creators[creator_type] = arr_of_creators.map do |creator_name|
        if creator = Creator.find_by(name: creator_name)
          creator
        else
          Creator.create name: creator_name
        end
      end
    end
    creators
  end

  def build_publisher(comic_hash)
    if publisher = Publisher.find_by(name: comic_hash[:publisher])
      publisher
    else
      Publisher.create name: comic_hash[:publisher]
    end
  end

  def map_params_to_model(comic_hash)
    { diamond_code: comic_hash[:diamond_id], 
      title: comic_hash[:title],
      issue_number: comic_hash[:issue_number], 
      preview: comic_hash[:preview],
      suggested_price: BigDecimal.new(comic_hash[:suggested_price].gsub /\$/, ''), 
      item_type: comic_hash[:type],
      shipping_date: comic_hash[:shipping_date]
    }
  end
end
