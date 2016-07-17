class DiamondComicsParser
  CURRENT_WEEK = 'http://www.previewsworld.com/shipping/newreleases.txt'.freeze
  NEXT_WEEK = 'http://www.previewsworld.com/shipping/upcomingreleases.txt'.freeze
  CATALOG = 'http://www.previewsworld.com/Catalog/'.freeze
  ROOT_URL = 'http://www.previewsworld.com'.freeze

  def get_page(page_url)
    url = URI.parse page_url
    Net::HTTP.get url
  end

  def parse_wednesday_date(page)
    match = page.match /(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{4})/ 
    return Date.new match[:year].to_i, match[:month].to_i, match[:day].to_i if match
    ''
  end

  def parse_diamond_codes(page, parse_for = :all)
    diamond_ids = []
    case parse_for
    when :all
      page.each_line do |line|
        matched = line.match /(?<code>[A-Z]{3}\d+)\s.+/
        diamond_ids << matched[:code] if matched
      end
    when :comics
      break_flag = false
      stop_after = "COMICS & GRAPHIC NOVELS" + "\r\n"
      
      page.each_line do |line|
        break if break_flag && line.match(/^[A-Z ]+\r\n/)
        break_flag = true if line == stop_after
        if identify_item_type(line) != 'merchandise'
          matched = line.match /(?<code>[A-Z]{3}\d+)\s.+/
          diamond_ids << matched[:code] if matched
        end
      end
    when :merchandise
      page.each_line do |line|
        if identify_item_type(line) == 'merchandise'
          matched = line.match /(?<code>[A-Z]{3}\d+)\s.+/
          diamond_ids << matched[:code] if matched
        end
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
    doc = Nokogiri::HTML(page)
    {
      diamond_id: parse_diamond_id(doc),
      title: parse_title(doc),
      issue_number: parse_issue_number(doc),
      publisher: parse_publisher(doc),
      creators: parse_creators(doc),
      preview: parse_preview(doc),
      suggested_price: parse_suggested_price(doc),
      type: parse_item_type(doc),
      shipping_date: parse_shipping_date(doc),
      additional_info: parse_additional_info(doc),
      cover_image_url: parse_cover_image(doc)
    }
  end

  SELECTORS = { description: '.Title',
                cover_image: '#MainContentImage',
                publisher: '.Publisher',
                creators: '.Creators',
                preview: '.Text',
                price: '.SRP',
                diamond_id: '.ItemCode',
                shipping_date: '.ReleaseDate'
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
    return 'merchandise' if description.match /\bPOSTER\b/
    matched = description.match /\b(?<type>HC|SC|TP|GN|OGN)\b/
    matched = description.match /(?<type>#)/ unless matched
    return ITEM_TYPES[matched[:type]] if matched
    'merchandise'
  end

  def build_additional_info(description)
    add_info = {}
    add_info[:variant_cover] = true if description.match /\b(?:CVR)\b/
    if match = description.match(/(?<volume>BOOK|VOL)\s(?<number>\d{1,2})/)
      add_info[match[:volume].downcase.to_sym] = match[:number] 
    end
    if match = description.match(/(?<number>\d+)[A-Z]{2}\sPTG/)
      add_info[:reprint_number] = match[:number] 
    end
    add_info[:mature_rating] = true if description.match(/\(MR\)/)
    add_info
  end

  def page_found?(page)
    page.match(/PAGENOTFOUND/i).nil?
  end

  def parse_additional_info(noko_nodes)
    desc = get_description(noko_nodes)
    build_additional_info desc
  end
  
  def parse_item_type(noko_nodes)
    desc = get_description(noko_nodes)
    identify_item_type desc
  end

  def parse_title(noko_nodes)
    desc = get_description noko_nodes

    item_type = identify_item_type desc
    case item_type
    #when 'hardcover', 'softcover', 'trade_paperback'
    #when 'graphic_novel'
    when 'single_issue'
      matched = desc.match /(?<title>[\w\s\W]+)#(?<number>\d+)/i
      return matched[:title].gsub(/#\d+/, '').strip if matched
    else
      return desc
    end
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
    return ROOT_URL + img_node.attr('src').value unless img_node.empty?
    ''
  end

  def parse_publisher(noko_nodes)
    publ_node = noko_nodes.css SELECTORS[:publisher]
    return publ_node.inner_text.strip unless publ_node.empty?
    ''
  end

  def build_creators_hash(writers = [], artists = [], cover_artists = [])
    {
      writers: filter_creators_string(writers), 
      artists: filter_creators_string(artists), 
      cover_artists: filter_creators_string(cover_artists)
    }
  end

  def filter_creators_string(creators)
    #should probably gsub out & Various and TBD
    creators.map do |creator|
      creator.gsub(/\s{2,}/, ' ')
             .gsub(/(?:& Various|Various|TBD)/, '')
             .split(',')
             .map(&:strip)
    end.flatten.reject(&:empty?)
  end

  def parse_creators(noko_nodes)
    creators_node = noko_nodes.css SELECTORS[:creators]
    creators_text = creators_node.inner_text.strip
    writers, artists, cover_artists = [], [], []

    creators_text.scan(/\((?:W|A|CA|W\/A|W\/A\/CA|A\/CA|W\/CA)\)[\s]*[\p{L}.,'&\s\-]+/).each do |creators_block|
      creators = creators_block.match /\(.+\)[\W\s]+(?<list>[\p{L}\W\s]+)/
      writers << creators[:list].strip if creators_block.match /(?<=\(|\/)W(?=\)|\/)/
      artists << creators[:list].strip if creators_block.match /(?<=\(|\/)A(?=\)|\/)/
      cover_artists << creators[:list].strip if creators_block.match /(?<=\(|\/)CA(?=\)|\/)/
    end
    build_creators_hash writers, artists, cover_artists
  end

  def parse_preview(noko_nodes)
    preview_node = noko_nodes.css SELECTORS[:preview]
    unless preview_node.empty?
      only_text = preview_node.children.select(&:text?)
      return only_text.map { |e| e.to_s.strip }.reject(&:empty?).join
    end
    ''
  end

  def parse_diamond_id(noko_nodes)
    diamond_id_node = noko_nodes.css SELECTORS[:diamond_id]
    return diamond_id_node.inner_text.strip unless diamond_id_node.empty?
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
    matched = date_node.inner_text.match /in shops:\s+(?<date>[\w\W\s]+)/i
    return Date.parse(matched[:date]) if matched
    ''
  end
  
end
