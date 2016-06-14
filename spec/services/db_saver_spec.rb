require 'rails_helper'

RSpec.describe DBSaver do
  let(:weekly_list) { WeeklyList.create }
  let(:db_saver) { DBSaver.new(weekly_list) }
  let(:valid_comic_hash) do
    {
      title: 'ABE SAPIEN',
      issue_number: '34',
      publisher: 'DARK HORSE COMICS',
      creators: { writers: ['Mike Mignola', 'Scott Allie'], 
                  artists: ['Sebastian Fiumara'], 
                  cover_artists: ['Sebastian Fiumara']},
      preview: 'In this standalone story, Abe seeks answers in his most crucial and secret place of origin, where his destiny is revealed.',
      suggested_price: '$3.99',
      type: 'single_issue',
      diamond_id: 'APR160066',
      shipping_date: Date.new(2016, 6, 8),
      additional_info: { variant_cover: true,
                         reprint_number: 2 }
    }
  end
  
  context 'persists to database' do
    it 'publisher' do
      expect { db_saver.persist_to_db valid_comic_hash }.to change { Publisher.count }.by(1)
      expect(Publisher.find_by(name: 'DARK HORSE COMICS').name).to eq('DARK HORSE COMICS')
    end

    it 'creators' do
      expect { db_saver.persist_to_db valid_comic_hash }.to change { Creator.count }.by(3)
      comic = Comic.find_by diamond_code: 'APR160066' 
      expect(comic.writers.map &:name).to eq(['Mike Mignola', 'Scott Allie'])
      expect(comic.artists.map &:name).to eq(['Sebastian Fiumara'])
      expect(comic.cover_artists.map &:name).to eq(['Sebastian Fiumara'])
    end

    it 'comic' do
      expect { db_saver.persist_to_db valid_comic_hash }.to change { Comic.count }.by(1)
      comic = Comic.find_by diamond_code: 'APR160066' 
      expect(comic.diamond_code).to eq 'APR160066'
      expect(comic.title).to eq 'ABE SAPIEN'
      expect(comic.issue_number).to eq 34
      expect(comic.item_type).to eq 'single_issue'
      expect(comic.preview).to eq 'In this standalone story, Abe seeks answers in his most crucial and secret place of origin, where his destiny is revealed.'
      expect(comic.suggested_price).to eq BigDecimal.new("3.99")
      expect(comic.shipping_date).to eq Date.new(2016, 6, 8)
      expect(comic.publisher.name).to eq 'DARK HORSE COMICS'
      expect(comic.is_variant).to eq true
      expect(comic.reprint_number).to eq 2
    end
  end

  it 'saves if no diamond_code in the db' do
    test_hash = {
                  title: 'SUPERMAN',
                  issue_number: '2',
                  publisher: 'DARK HORSE COMICS',
                  creators: { writers: ['Mike Mignola', 'Scott Allie'], 
                              artists: ['Sebastian Fiumara'], 
                              cover_artists: ['cover_artist_1']},
                  preview: 'stuff happens',
                  suggested_price: '$3.99',
                  type: 'single_issue',
                  diamond_id: '11111',
                  shipping_date: Date.new(2016, 6, 8),
                  additional_info: { variant_cover: true }
    }
    expect { db_saver.persist_to_db test_hash }.to change { Comic.count }.by(1)
  end
  
  it 'doesnt save if tuple with diamond_code already exists' do
    Fabricate(:comic) do
      diamond_code '11111'
      title 'SUPERMAN'
      issue_number 2
      item_type 'single_issue'
      cover_artists { [Fabricate(:creator, name: 'cover_artist_1')] }
      shipping_date Date.new(2016, 6, 8)
    end

    test_hash = {
                  title: 'SUPERMAN',
                  issue_number: '2',
                  publisher: 'DARK HORSE COMICS',
                  creators: { writers: ['Mike Mignola', 'Scott Allie'], 
                              artists: ['Sebastian Fiumara'], 
                              cover_artists: ['cover_artist_1']},
                  preview: 'stuff happens',
                  suggested_price: '$3.99',
                  type: 'single_issue',
                  diamond_id: '11111',
                  shipping_date: Date.new(2016, 6, 8),
                  additional_info: { variant_cover: true }
    }
    expect { db_saver.persist_to_db test_hash }.not_to change { Comic.count }
  end
end
