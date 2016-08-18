json.total @publishers.size
json.publishers @publishers.each do |publisher|
  json.name publisher.name
  json.total_comics publisher.comics.size
end
