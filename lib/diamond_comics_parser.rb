class DiamondComicsParser
  CURRENT_WEEK = 'http://www.previewsworld.com/shipping/newreleases.txt'
  NEXT_WEEK = 'http://www.previewsworld.com/shipping/upcomingreleases.txt'
  CATALOG = 'http://www.previewsworld.com/Catalog/'

  def get_page(page_url)
    url = URI.parse page_url
    Net::HTTP.get url
  end

  def parse_wednesday_date(page)
    match = page.match /(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{4})/ 
    return Date.new match[:year].to_i, match[:month].to_i, match[:day].to_i if match
    ''
  end

  def parse_diamond_codes(page)
    diamond_ids = []
    stop_after = "COMICS & GRAPHIC NOVELS" + "\r\n"
    break_flag = false
    
    page.each_line do |line|
      break if break_flag && line.match(/^[A-Z ]+\r\n/)
      break_flag = true if line == stop_after
      if identify_item_type(line) != 'merchandise'
        matched = line.match /(?<code>[A-Z]{3}\d+)\s.+/
        diamond_ids << matched[:code] if matched
      end
    end
    diamond_ids
  end

  def url_for_item(diamond_id)
    CATALOG + diamond_id.to_s
  end

  def get_comic_page(code)
    get_page url_for_item(code)
  end

  def parse_comic_info(page)
    doc = Nokogiri::HTML(page).css('.StockCode')
    {
      diamond_id: parse_diamond_id(doc),
      title: parse_title(doc),
      issue_number: parse_issue_number(doc),
      publisher: parse_publisher(doc),
      creators: parse_creators(doc),
      preview: parse_preview(doc),
      suggested_price: parse_suggested_price(doc),
      type: parse_item_type(doc),
      shipping_date: parse_shipping_date(doc)
    }
  end

  def pretty_print(comic)
    puts '----------------------'
    puts comic[:diamond_id]
    puts comic[:title]
    puts comic[:issue_number]
    puts comic[:publisher]
    puts 'Creators:'
    comic[:creators].each do |key, value|
      puts "#{key}: #{value.inspect}"
    end
    puts comic[:preview]
    puts comic[:type]
    puts comic[:suggested_price]
  end

  def test_process(ids = nil)
    list_page = get_page CURRENT_WEEK
    diamond_ids = parse_diamond_codes(list_page)
    ids = diamond_ids.size unless ids
    diamond_ids.first(ids).each do |code|
      comic_page = get_comic_page code
      comic = parse_comic_info comic_page
      pretty_print comic
    end
  end

  SELECTORS = { description: '.StockCodeDescription',
                cover_image: '.StockCodeImage a',
                publisher: '.StockCodePublisher',
                creators: '.StockCodeCreators',
                preview: '.PreviewsHtml',
                price: '.StockCodeInfo .StockCodeSrp',
                diamond_id: '.StockCodeDiamdNo',
                shipping_date: '.StockCodeInShopsDate'
  }.freeze

  def get_description(noko_nodes)
    desc_node = noko_nodes.css SELECTORS[:description]
    desc = desc_node.inner_text
  end

  ITEM_TYPES = {
    'HC' => 'hardcover',
    'SC' => 'softcover',
    '#' => 'single_issue',
    'TP' => 'trade_paperback',
    'GN' => 'graphic_novel',
    'OGN' => 'graphic_novel'
  }.freeze

  def identify_item_type(description)
    matched = description.match /\b(?<type>HC|SC|TP|GN|OGN)\b/
    matched = description.match /(?<type>#)/ unless matched
    return ITEM_TYPES[matched[:type]] if matched
    'merchandise'
  end
  
  def parse_item_type(noko_nodes)
    desc = get_description(noko_nodes)
    identify_item_type desc
  end

  def parse_title(noko_nodes)
    desc = get_description noko_nodes
    matched = desc.match /(?<title>(\w|\s)+)#(?<number>\d+)/i
    return matched[:title].strip if matched
    ''
  end

  def parse_issue_number(noko_nodes)
    desc = get_description noko_nodes
    matched = desc.match /(?<title>(\w|\s)+)#(?<number>\d+)/i
    return matched[:number] if matched
    ''
  end

  def parse_cover_image(noko_nodes)
    img_node = noko_nodes.css SELECTORS[:cover_image]
    return img_node.attr('href').value unless img_node.empty?
    ''
  end

  def parse_publisher(noko_nodes)
    publ_node = noko_nodes.css SELECTORS[:publisher]
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
    creators_node = noko_nodes.css SELECTORS[:creators]
    creators_text = creators_node.inner_text

    if creators_text.match /\(W\/A\/CA\)/
      matched = creators_text.match /\(W\/A\/CA\)(?:\W|\s)+(?<writer>.+)/i
      return build_creators_hash matched[:writer], matched[:writer], matched[:writer] if matched
    elsif creators_text.match /\(W\/A\)/
      matched = creators_text.match /\(W\/A\)(?:\W|\s)+(?<writer_artist>.+)(?:\W|\s)+\(CA\)(?:\W|\s)(?<cover_artist>.+)/i
      return build_creators_hash matched[:writer_artist], matched[:writer_artist], matched[:cover_artist] if matched
    elsif creators_text.match /\(A\/CA\)/
      if creators_text.match /\(W\)/
        matched = creators_text.match /\(W\)(?:\W|\s)+(?<writer>.+)(?:\W|\s)+\(A\/CA\)(?:\W|\s)(?<artist>.+)/i
        return build_creators_hash matched[:writer], matched[:artist], matched[:artist] if matched
      else
        matched = creators_text.match /\(A\/CA\)(?:\W|\s)(?<artist>.+)/i
        return build_creators_hash [], matched[:artist], matched[:artist] if matched
      end
    else
      matched = creators_text.match /\(W\)(?<writer>.+)\(A\)(?<artist>.+)\(CA\)(?<cover_artist>.+)/i
      return build_creators_hash matched[:writer], matched[:artist], matched[:cover_artist] if matched
    end
    return build_creators_hash
  end

  def parse_preview(noko_nodes)
    preview_node = noko_nodes.css SELECTORS[:preview]
    return preview_node.inner_text.strip unless preview_node.empty?
    ''
  end

  def parse_diamond_id(noko_nodes)
    diamond_id_node = noko_nodes.css SELECTORS[:diamond_id]
    matched = diamond_id_node.inner_text.match /item code:\s+(?<diamond_id>(\w|\s|\.|\$)+)/i
    return matched[:diamond_id].strip if matched
    ''
  end

  def parse_suggested_price(noko_nodes)
    price_node = noko_nodes.css SELECTORS[:price]
    matched = price_node.inner_text.match /srp:\s+(?<price>(\w|\s|\.|\$)+)/i
    return matched[:price].strip if matched
    ''
  end

  def parse_shipping_date(noko_nodes)
    date_node = noko_nodes.css SELECTORS[:shipping_date]
    matched = date_node.inner_text.match /in shops:\s+(?<month>\d+)\/(?<day>\d+)\/(?<year>\d+)/i
    return Date.new matched[:year].to_i, matched[:month].to_i, matched[:day].to_i if matched
    ''
  end
  
end
