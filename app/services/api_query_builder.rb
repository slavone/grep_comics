class ApiQueryBuilder
  NAME_SANITIZER = /^[\s\w\d]+/
  DATE_SANITIZER = /^\d{4}-\d{2}-\d{2}/

  def self.sanitize_creators(unsafe_creators)
    unsafe_creators.split(',').map do |creator|
      if m = creator.match(NAME_SANITIZER)
        m.to_s
      end
    end.compact
  end

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
      creators = ApiQueryBuilder.sanitize_creators query_input
      comics_in = Comic.filtered_by_creators(creators).map(&:id).join(',')
      "comics.id IN (#{comics_in})"
    end,
    writers: ->(query_input) do
      creators = ApiQueryBuilder.sanitize_creators query_input
      comics_in = Comic.filtered_by_creators_of_type(creators, :writer)
      "comics.id IN (#{comics_in.map(&:id).join(',')})"
    end,
    artists: ->(query_input) do
      creators = ApiQueryBuilder.sanitize_creators query_input
      comics_in = Comic.filtered_by_creators_of_type(creators, :artist)
      "comics.id IN (#{comics_in.map(&:id).join(',')})"
    end,
    cover_artists: ->(query_input) do
      creators = ApiQueryBuilder.sanitize_creators query_input
      comics_in = Comic.filtered_by_creators_of_type(creators, :cover_artist)
      "comics.id IN (#{comics_in.map(&:id).join(',')})"
    end,
    shipping_date: ->(query_input) do
      if m = query_input.match(DATE_SANITIZER)
        "comics.shipping_date = '#{m.to_s}'"
      end
    end,
    has_variant_cover: ->(query_input) do
      if m = query_params.match(/(true)/i)
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
    item_type: ->(query_input) do
      if m = query_input.match(/[\w]+/)
        "comics.item_type = '#{m.to_s}'"
      end
    end
  }.freeze

  def build_query_for_comics(params)
    present_params = params.keys.map(&:to_sym) & COMICS_QUERIES.keys
    build_query do |query|
      present_params.each do |param|
        query << COMICS_QUERIES[param].call(params[param])
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
