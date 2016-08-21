Fabricator(:weekly_list) do
  list 'some data'
  wednesday_date { Date.today }
end
