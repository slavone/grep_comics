json.total Creator.count
json.creators @creators.each do |creator|
  json.name creator.name
  json.number_of_writer_credits creator.writer_credits.size
  json.number_of_artist_credits creator.artist_credits.size
  json.number_of_cover_artist_credits creator.cover_artist_credits.size
end
