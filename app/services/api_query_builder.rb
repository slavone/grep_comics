class ApiQueryBuilder
  NAME_SANITIZER = /^[\s\w\d]+/
  DATE_SANITIZER = /^\d{4}-\d{2}-\d{2}/

  def self.sanitize_array(string_as_array)
    string_as_array.split(',').map do |creator|
      if m = creator.match(NAME_SANITIZER)
        m.to_s.strip
      end
    end.compact
  end

  PUBLISHERS_QUERIES = {
    names: ->(query_input) do
      names = ApiQueryBuilder.sanitize_array query_input
      "publishers.name ~* '(#{names.join('|')})'"
    end
  }.freeze

  CREATORS_QUERIES = {
    names: ->(query_input) do
      names = ApiQueryBuilder.sanitize_array query_input
      "creators.name ~* '(#{names.join('|')})'"
    end,
    name: ->(query_input) do
      if m = query_input.match(NAME_SANITIZER)
        "creators.name ILIKE '%#{m.to_s}%'"
      end
    end
  }.freeze

  COMICS_QUERIES = {
    publisher: ->(query_input) do
      if m = query_input.match(NAME_SANITIZER)
        "publishers.name = '#{m.to_s.upcase}'"
      end
    end,
    title: ->(query_input) do
      if m = query_input.match(NAME_SANITIZER)
        "comics.title ILIKE '%#{m.to_s}%'"
      end
    end,
    creators: ->(query_input) do
      creators = ApiQueryBuilder.sanitize_array query_input
      comics_in = Comic.filtered_by_creators(creators).map(&:id).join(',')
      comics_in = "0" if comics_in.empty?
      "comics.id IN (#{comics_in})"
    end,
    writers: ->(query_input) do
      creators = ApiQueryBuilder.sanitize_array query_input
      comics_in = Comic.filtered_by_creators_of_type(creators, :writer).map(&:id).join(',')
      comics_in = "0" if comics_in.empty?
      "comics.id IN (#{comics_in})"
    end,
    artists: ->(query_input) do
      creators = ApiQueryBuilder.sanitize_array query_input
      comics_in = Comic.filtered_by_creators_of_type(creators, :artist).map(&:id).join(',')
      comics_in = "0" if comics_in.empty?
      "comics.id IN (#{comics_in})"
    end,
    cover_artists: ->(query_input) do
      creators = ApiQueryBuilder.sanitize_array query_input
      comics_in = Comic.filtered_by_creators_of_type(creators, :cover_artist).map(&:id).join(',')
      comics_in = "0" if comics_in.empty?
      "comics.id IN (#{comics_in})"
    end,
    shipping_date: ->(query_input) do
      if m = query_input.match(DATE_SANITIZER)
        "comics.shipping_date = '#{m.to_s}'"
      end
    end,
    has_variant_covers: ->(query_input) do
      if m = query_input.match(/(true)/i)
        "comics.is_variant = '#{m.to_s}'"
      end
    end,
    issue_number: ->(query_input) do
      if m = query_input.match(/^\d+/)
        "comics.issue_number = '#{m.to_s}'"
      end
    end,
    reprint: ->(query_input) do
      if m = query_input.match(/(true)/i)
        "comics.reprint_number IS NOT NULL"
      end
    end,
    type: ->(query_input) do
      if m = query_input.match(/[\w]+/)
        "comics.item_type = '#{m.to_s}'"
      end
    end
  }.freeze

  def build_query_for_comics(params)
    build_query do |query|
      params.keys.map(&:to_sym).each do |param|
        query << COMICS_QUERIES[param]&.call(params[param])
      end
    end
  end

  def build_query_for_publishers(params)
    build_query do |query|
      params.keys.map(&:to_sym).each do |param|
        query << PUBLISHERS_QUERIES[param]&.call(params[param])
      end
    end
  end

  def build_query_for_creators(params)
    build_query do |query|
      params.keys.map(&:to_sym).each do |param|
        query << CREATORS_QUERIES[param]&.call(params[param])
      end
    end
  end

  private

  def build_query
    query = []
    yield query
    query.compact.join(' AND ')
  end
end
