require 'rails_helper'

RSpec.describe DBSaver do
  let(:db_saver) { DBSaver.new }
  let(:valid_comic_hash) do
    {
      title: 'ABE SAPIEN',
      issue_number: '34',
      publisher: 'DARK HORSE COMICS',
      creators: { writers: ['Mike Mignola', 'Scott Allie'], artists: ['Sebastian Fiumara'], cover_artists: ['Sebastian Fiumara']},
      preview: 'In this standalone story, Abe seeks answers in his most crucial and secret place of origin, where his destiny is revealed.',
      suggested_price: '$3.99',
      type: 'single_issue',
      diamond_id: 'APR160066',
      shipping_date: Date.new(2016, 6, 8)
    }
  end

  context 'persists to database' do
    it 'created publisher' do
      expect { db_saver.persist_to_db valid_comic_hash }.to change { Publisher.count }
    end

    it 'created writers' do
      expect { db_saver.persist_to_db valid_comic_hash }.to change { Creator.count }
    end

    it 'created comic' do
      expect { db_saver.persist_to_db valid_comic_hash }.to change { Comic.count }
    end

    it 'with all valid associations' do
      db_saver.persist_to_db valid_comic_hash
      comic = Comic.find_by diamond_code: 'APR160066' 
      expect(comic.diamond_code).to eq 'APR160066'
      expect(comic.title).to eq 'ABE SAPIEN'
      expect(comic.issue_number).to eq 34
      expect(comic.item_type).to eq 'single_issue'
      expect(comic.preview).to eq 'In this standalone story, Abe seeks answers in his most crucial and secret place of origin, where his destiny is revealed.'
      expect(comic.suggested_price).to eq BigDecimal.new("3.99")
      expect(comic.shipping_date).to eq Date.new(2016, 6, 8)
      expect(comic.publisher.name).to eq 'DARK HORSE COMICS'
      expect(comic.writers.map &:name).to eq(['Mike Mignola', 'Scott Allie'])
    end
  end
end
