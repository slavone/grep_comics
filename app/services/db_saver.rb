class DBSaver
  def initialize
    @logger = Logger.new "#{Rails.root}/log/db_saver.log"
  end

  def persist_to_db(comic_hash)
    log '--------------------------------------------'
    log "Trying to persist comic #{comic_hash.inspect}"
    if comic_hash[:type] == 'single_issue'
      log 'Its a single issue'
      persist_single_issue(comic_hash)
    else
      log 'Its a collected edition'
      persist_collected_edition(comic_hash)
    end
  end

  private

  def log(message)
    @logger.info message
  end

  def persist_collected_edition(comic_hash)
    comic_already_exists = Comic.find_by title: comic_hash[:title]

    if comic_already_exists
      log 'This comic already exists in the database. Quitting'
      return
    else
      save_new_comic(comic_hash)
      log "Persisted comic #{comic_hash[:title]}"
    end
  end

  def persist_single_issue(comic_hash)
    comic_already_exists = query_single_issue comic_hash[:title], 
                                              comic_hash[:issue_number],
                                              comic_hash[:shipping_date].try(:year)

    if comic_already_exists
      log 'This comic already exists in the database'
      if comic_hash[:additional_info][:variant_cover]
        log 'But its tagged as variant, so it may have unassociated cover artist'
        associate_variant_cover_artists comic_already_exists, 
                                        comic_hash[:creators][:cover_artists]
      else
        log 'Quitting'
        return
      end
    else
      save_new_comic(comic_hash)
      log "Persisted comic #{comic_hash[:title]} #{comic_hash[:issue_number]}"
    end
  end

  def associate_variant_cover_artists(existing_comic, cover_artists)
    associated_cover_artists = existing_comic.cover_artists
    cover_artists.each do |cover_artist|
      unless associated_cover_artists.map(&:name).include?(cover_artist)
        log "Cover artist #{cover_artist} wasnt associated before, adding..."
        associated_cover_artists << fetch_or_persist_creator(cover_artist)
      end
    end
  end

  def save_new_comic(comic_hash)
    comic_params = map_params_to_model(comic_hash)
    publisher = build_publisher comic_hash
    creators = build_creators comic_hash[:creators]
    comic_params.merge!(publisher: publisher).merge! creators
    Comic.create comic_params
  end

  def cover_artists_already_associated(comic, cover_artists)
    comic.cover_artists.map(&:name).include? cover_artists
  end

  def query_single_issue(title, issue_number, year)
    Comic.where(title: title, 
                issue_number: issue_number)
         .where('extract(year from shipping_date) = ?', year).first
  end

  def fetch_or_persist_creator(name)
    if creator = Creator.find_by(name: name)
      log "Creator #{name} is already in the db. Fetching..."
      creator
    else
      log "Persisted new creator #{name}"
      Creator.create name: name
    end
  end

  def build_creators(creators_hash)
    creators = {}

    creators_hash.each do |creator_type, arr_of_creators|
      creators[creator_type] = arr_of_creators.map do |creator_name|
        fetch_or_persist_creator(creator_name)
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
