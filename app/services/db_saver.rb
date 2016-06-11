class DBSaver
  def persist_to_db(comic_hash)
    unless Comic.find_by diamond_code: comic_hash[:diamond_id]
      #TODO more strict search, single issues with variant covers
      comic_params = map_params_to_model(comic_hash)
      publisher = build_publisher comic_hash
      writers = build_writers comic_hash[:creators][:writers]
      comic_params.merge! publisher: publisher, writers: writers
      Comic.create comic_params
    end
  end

  private

  def build_writers(writers)
    writers.map do |writer_name|
      if writer = Creator.find_by(name: writer_name)
        writer
      else
        Creator.new name: writer_name
      end
    end
  end

  def build_publisher(comic_hash)
    if publisher = Publisher.find_by(name: comic_hash[:publisher])
      publisher
    else
      Publisher.new name: comic_hash[:publisher]
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
