require 'rails_helper'

RSpec.describe Creator, :type => :model do
  let(:creator) do
    Fabricate(:creator, name: 'some guy')
  end

  context 'has' do
    it 'comics as writer' do
      Fabricate(:comic, writers: [creator], title: 'SUPERMAN')
      expect(creator.comics_as_writer.map &:title).to include('SUPERMAN')
    end

    it 'comics as artist' do
      Fabricate(:comic, artists: [creator], title: 'SUPERMAN')
      expect(creator.comics_as_artist.map &:title).to include('SUPERMAN')
    end

    it 'comics as cover artist' do
      Fabricate(:comic, cover_artists: [creator], title: 'SUPERMAN')
      expect(creator.comics_as_cover_artist.map &:title).to include('SUPERMAN')
    end
  end

  it 'worked for publishers' do
    creator = Creator.create name: 'test'
    (1..3).each do |i|
      Fabricate(:comic) do
        writers { [creator] }
        title "comic_#{i}"
        publisher { Fabricate(:publisher, name: "publisher_#{i}") }
      end
    end
    Fabricate(:publisher, name: 'not in the list')
    expected_publishers = creator.worked_for_publishers.map &:name
    expect(expected_publishers).to eq( %w( publisher_1 publisher_2 publisher_3) )
    expect(expected_publishers).not_to include( 'not in the list' )
  end

end
