require 'rails_helper'

RSpec.describe Comic, :type => :model do
  let(:comic) do
    Fabricate(:comic, title: 'SUPERMAN') do
      writers { [Fabricate(:creator, name: 'Geoff Johns')] }
      artists { [Fabricate(:creator, name: 'Frank Quitely')] }
      cover_artists { [Fabricate(:creator, name: 'Frank Frazetta')] }
      publisher { Fabricate(:publisher, name: 'some publisher') }
      weekly_list { Fabricate(:weekly_list) }
    end
  end

  context 'belongs_to' do
    it 'publisher' do
      expect(comic.publisher.name).to eq('some publisher')
    end

    it 'weekly_list' do
      expect(comic.weekly_list.wednesday_date).to eq(Date.today)
    end
  end

  context 'has' do
    it 'writers' do
      expect(comic.writers.map &:name).to include('Geoff Johns')
    end

    it 'artists' do
      expect(comic.artists.map &:name).to include('Frank Quitely')
    end

    it 'cover artists' do
      expect(comic.cover_artists.map &:name).to include('Frank Frazetta')
    end
  end

  context 'searchable by creator names' do
    before do
      (1..5).each do |i|
        Fabricate(:comic, title: "comic_#{i}") do
          writers { [Fabricate(:creator, name: "writer_#{i}")] }
          artists { [Fabricate(:creator, name: "artist_#{i}")] }
          cover_artists { [Fabricate(:creator, name: "cover_artist_#{i}")] }
        end
      end
    end

    context 'filtered_by_creators' do
      it 'finds comics where creators are credited' do
        comics = Comic.filtered_by_creators %w(writer_1 artist_3 cover_artist_5)
        expect(comics.map(&:title)).to eq( %w(comic_1 comic_3 comic_5) )
      end
    end

    context 'filtered_by_creators_of_type' do
      it 'finds comics where creators are credited as writers' do
        artist_3 = Creator.find_by name: 'artist_3'
        Comic.find_by(title: 'comic_3').writer_credits.create creator: artist_3
        comics = Comic.filtered_by_creators_of_type %w(writer_1 artist_3 cover_artist_5), :writer
        expect(comics.map(&:title)).to eq( %w(comic_1 comic_3) )
      end

      it 'finds comics where creators are credited as artists' do
        writer_5 = Creator.find_by name: 'writer_5'
        Comic.find_by(title: 'comic_1').artist_credits.create creator: writer_5
        comics = Comic.filtered_by_creators_of_type %w(artist_3 writer_5), :artist
        expect(comics.map(&:title)).to eq( %w(comic_1 comic_3) )
      end

      it 'finds comics where creators are credited as cover artists' do
        writer_5 = Creator.find_by name: 'writer_5'
        Comic.find_by(title: 'comic_5').cover_artist_credits.create creator: writer_5
        comics = Comic.filtered_by_creators_of_type %w(cover_artist_1 writer_5), :cover_artist
        expect(comics.map(&:title)).to eq( %w(comic_1 comic_5) )
      end
    end
  end

end
