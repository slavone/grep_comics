json.total @creators.size
json.creators @creators.each do |creator|
  json.name creator.name
  json.totalWriterCredits creator.writer_credits.size
  json.totalArtistCredits creator.artist_credits.size
  json.totalCoverArtistCredits creator.cover_artist_credits.size
end
