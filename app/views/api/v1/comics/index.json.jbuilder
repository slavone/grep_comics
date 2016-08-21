json.total @comics&.size || 0
json.comics @comics&.each do |comic|
  json.diamond_code comic.diamond_code
  json.title comic.title
  json.type comic.item_type
  json.issue_number comic.issue_number if comic.issue_number
  json.has_variant_covers true if comic.is_variant
  json.reprint_number comic.reprint_number if comic.reprint_number
  json.publisher comic.publisher.name
  json.shipping_date comic.shipping_date
  json.preview comic.preview
  json.original_cover_url comic.cover_image
  json.creators do
    json.writers comic.writers.each do |writer|
      json.name writer.name
    end
    json.artists comic.artists.each do |artist|
      json.name artist.name
    end
    json.cover_artists comic.cover_artists.each do |artist|
      json.name artist.name
    end
  end
end
