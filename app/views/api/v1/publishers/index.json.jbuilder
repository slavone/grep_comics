json.total Publisher.count
json.publishers @publishers.each do |publisher|
  json.name publisher.name
  json.total_comics publisher.comics.size
end
