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
    comic[:title], comic[:issue_number] = parse_description(doc)
    comic[:publisher] = parse_publisher(doc)
    comic[:creators] = parse_creators(doc)
    comic[:preview] = parse_preview(doc)
    comic[:suggested_price] = parse_suggested_price(doc)
    #types single_issue, tpb, hardcover, graphic novel or merch
    comic
  end

  SELECTORS = { description: '.StockCodeDescription',
                cover_image: '.StockCodeImage a',
                publisher: '.StockCodePublisher',
                creators: '.StockCodeCreators',
                preview: '.PreviewsHtml',
                price: '.StockCodeInfo .StockCodeSrp'
              }.freeze

  def get_node(doc, selector)
    doc.css selector
  end

  def get_description(noko_nodes)
    desc_node = get_node noko_nodes, SELECTORS[:description]
    desc = desc_node.inner_text
  end

  def identify_type(description)
    if description.match /\bHC\b/
      'hardcover'
    elsif description.match /#\d+/
      'single_issue'
    elsif description.match /\bTP\b/
      'trade_paperback'
    elsif description.match(/\bGN\b/) || description.match(/\bOGN\b/)
      'graphic_novel'
    else
      'merchandise'
    end
  end

  def parse_description(noko_nodes)
    desc = get_description(noko_nodes)
    matched = desc.match /(?<title>(\w|\s)+)#(?<number>\d+)/i
    return matched[:title].strip, matched[:number] if matched
    ''
  end

  def parse_cover_image(noko_nodes)
    img_node = get_node noko_nodes, SELECTORS[:cover_image]
    return img_node.attr('href').value unless img_node.empty?
    ''
  end

  def parse_publisher(noko_nodes)
    publ_node = get_node noko_nodes, SELECTORS[:publisher]
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
    creators_node = get_node noko_nodes, SELECTORS[:creators]

    if creators_node.inner_text.match /\(W\/A\/CA\)/
      matched = creators_node.inner_text.match /\(W\/A\/CA\)(?:\W|\s)+(?<writer>(\w|\s|,)+)/i
      return build_creators_hash matched[:writer], matched[:writer], matched[:writer] if matched
    elsif creators_node.inner_text.match /\(W\/A\)/
      matched = creators_node.inner_text.match /\(W\/A\)(?:\W|\s)+(?<writer_artist>(\w|\s|,)+)(?:\W|\s)+\(CA\)(?:\W|\s)(?<cover_artist>(\w|\s|,)+)/i
      return build_creators_hash matched[:writer_artist], matched[:writer_artist], matched[:cover_artist] if matched
    elsif creators_node.inner_text.match /\(A\/CA\)/
      matched = creators_node.inner_text.match /\(W\)(?:\W|\s)+(?<writer>(\w|\s|,)+)(?:\W|\s)+\(A\/CA\)(?:\W|\s)(?<artist>(\w|\s|,)+)/i
      return build_creators_hash matched[:writer], matched[:artist], matched[:artist] if matched

    else
      matched = creators_node.inner_text.match /\(W\)(?:\W|\s)+(?<writer>(\w|\s|,)+)(?:\W|\s)+\(A\)(?:\W|\s)(?<artist>(\w|\s|,)+)(?:\W|\s)+\(CA\)(?:\W|\s)(?<cover_artist>(\w|\s|,)+)/i
      return build_creators_hash matched[:writer], matched[:artist], matched[:cover_artist] if matched
    end
    return build_creators_hash
  end

  def parse_preview(noko_nodes)
    preview_node = get_node noko_nodes, SELECTORS[:preview]
    return preview_node.inner_text.strip unless preview_node.empty?
    ''
  end

  def parse_suggested_price(noko_nodes)
    price_node = get_node noko_nodes, SELECTORS[:price]
    matched = price_node.inner_text.match /srp:\s+(?<price>(\w|\s|\.|\$)+)/i
    return matched[:price].strip if matched
    ''
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
