class DiamondComicsParser
  CURRENT_WEEK = 'http://www.previewsworld.com/shipping/newreleases.txt'
  NEXT_WEEK = 'http://www.previewsworld.com/shipping/upcomingreleases.txt'
  CATALOG = 'http://www.previewsworld.com/Catalog/'
  BLACKLISTED_WORDS = /(toys|magazines|merchandise|books)/i

  def url_for_item(diamond_id)
    CATALOG + diamond_id.to_s
  end

  def get_page(page_url)
    url = URI.parse page_url
    Net::HTTP.get url
  end

  def parse_wednesday_date(page)
    match = page.match /(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{4})/ 
    if match
      Date.parse "#{match[:day]}.#{match[:month]}.#{match[:year]}"
    else
      ''
    end
  end

  def get_comic_page(code)
    get_page url_for_item(code)
  end

  def parse_comic_info(page)
    comic = {}
    doc = Nokogiri::HTML(page).css('.StockCode')
    comic[:title] = match[:title]
    comic[:number] = match[:number]
    comic
  end

  def parse_description(noko_nodes)
    desc_css = '.StockCodeDescription'
    desc_node = noko_nodes.css desc_css
    matched = desc_node.inner_text.match /(?<title>(\w|\s)+)#(?<number>\d+)/i
    return matched[:title].strip, matched[:number] if matched
    ''
  end

  def parse_publisher(noko_nodes)
    publ_css = '.StockCodePublisher'
    publ_node = noko_nodes.css publ_css
    matched = publ_node.inner_text.match /publisher:\W+(?<publisher>(\w|\s)+)/i
    return matched[:publisher] if matched
    ''
  end

  def build_creators_hash(writers = [], artists = [], cover_artists = [])
    {
      writers: parse_creators_string(writers), 
      artists: parse_creators_string(artists), 
      cover_artists: parse_creators_string(cover_artists)
    }
  end

  def parse_creators_string(creators)
    creators.kind_of?(String) ? creators.split(',').map(&:strip) : creators
  end

  def parse_creators(noko_nodes)
    creators_css = '.StockCodeCreators'
    creators_node = noko_nodes.css creators_css

    if creators_node.inner_text.match /\(W\/A\/CA\)/
      puts 'FULL STACK BABY'
    elsif creators_node.inner_text.match /\(W\/A\)/
      puts 'writer/artist and cover artist'
    elsif creators_node.inner_text.match /\(A\/CA\)/
      matched = creators_node.inner_text.match /\(W\)(?:\W|\s)+(?<writer>(\w|\s|,)+)(?:\W|\s)+\(A\/CA\)(?:\W|\s)(?<artist>(\w|\s|,)+)/i
      puts matched.inspect
      return build_creators_hash matched[:writer], matched[:artist], matched[:artist] if matched

    else
      puts 'all different'
    end
    return build_creators_hash
  end
  
  def parse_diamond_codes(page)
    diamond_ids = []
    stop_after = "COMICS & GRAPHIC NOVELS" + "\r\n"
    break_flag = false
    
    page.each_line do |line|
      break if break_flag && line.match(/^[A-Z ]+\r\n/)
      break_flag = true if line == stop_after
      match_comic = line.match /(?<code>[A-Z]{3}\d+)\s.+/
      diamond_ids << match_comic[:code] if match_comic
    end
    diamond_ids
  end
end
