Fabricator(:comic) do
  diamond_code 'JAN160154'
  title 'SOME COMIC'
  issue_number 23
  preview 'Stuff happends'
  item_type { ['single_issue', 'hardcover', 'trade_paperback'].sample }
  suggested_price 3.99
  shipping_date Date.new(2016, 6, 8)
  publisher { Fabricate(:publisher, name: 'DC COMICS') }
  writers { [Fabricate(:creator)] }
  artists { [Fabricate(:creator)] }
  cover_artists { [Fabricate(:creator)] }
end
