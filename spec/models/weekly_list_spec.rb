require 'rails_helper'

RSpec.describe WeeklyList, :type => :model do
  let!(:weekly_list) { WeeklyList.create wednesday_date: Date.today }
  before do
    (1..3).each do |i|
      Fabricate(:comic, weekly_list: weekly_list) do
        publisher { Fabricate(:publisher, name: "publisher_#{i}") }
        writers { [Fabricate(:creator, name: "writer_#{i}")] }
        artists { [Fabricate(:creator, name: "artist_#{i}")] }
        cover_artists { [Fabricate(:creator, name: "cover_artist_#{i}")] }
      end
    end
  end

  context 'has' do
    it 'comics' do
      expect(weekly_list.comics.size).to eq(3)
    end
  end

  it 'fetches all publishers' do
    expect(weekly_list.all_publishers.map &:name).to eq( %w(publisher_1 publisher_2 publisher_3) )
  end

  it 'fetches all creators' do
    expected_creators = (1..3).reduce([]) do |arr, i|
      %w(writer artist cover_artist).each { |creator_type| arr << (creator_type + "_#{i}") }
      arr
    end.sort
    expect(weekly_list.all_creators.map &:name).to eq(expected_creators)
  end
end
