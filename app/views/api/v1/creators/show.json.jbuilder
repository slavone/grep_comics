json.name @creator.name
json.writtenComics @creator.comics_as_writer do |comic|
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
end
json.drawnComics @creator.comics_as_artist do |comic|
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
end
json.drawnCovers @creator.comics_as_cover_artist do |comic|
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
end
json.workedForPublishers @worked_for_publishers do |publisher|
  json.name publisher.name
end
