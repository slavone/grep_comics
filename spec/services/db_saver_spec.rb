require 'rails_helper'

RSpec.describe DBSaver do
  let(:db_saver) { DBSaver.new }
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
      additional_info: {}
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
    end
  end

  context 'edge cases' do
    context 'single issue' do
      before do
        Fabricate(:comic) do
          diamond_code '11111'
          title 'SUPERMAN'
          issue_number 2
          item_type 'single_issue'
          cover_artists { [Fabricate(:creator, name: 'cover_artist_1')] }
          shipping_date Date.new(2016, 6, 8)
        end
      end

      context 'doesnt save' do
        it 'same title, same issue_number and same year' do
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

      context 'saves' do
        it 'same title, issue_number but different year' do
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
                        shipping_date: Date.new(2015, 6, 8),
                        additional_info: {}
          }
          expect { db_saver.persist_to_db test_hash }.to change { Comic.count }.by(1)
        end

        it 'same title, different issue_number' do
          test_hash = {
                        title: 'SUPERMAN',
                        issue_number: '3',
                        publisher: 'DARK HORSE COMICS',
                        creators: { writers: ['Mike Mignola', 'Scott Allie'], 
                                    artists: ['Sebastian Fiumara'], 
                                    cover_artists: ['cover_artist_1']},
                        preview: 'stuff happens',
                        suggested_price: '$3.99',
                        type: 'single_issue',
                        diamond_id: '11111',
                        shipping_date: Date.new(2016, 6, 8),
                        additional_info: {}
          }
          expect { db_saver.persist_to_db test_hash }.to change { Comic.count }.by(1)
        end

        it 'different title' do
          test_hash = {
                        title: 'SUPERMAN 2.0',
                        issue_number: '3',
                        publisher: 'DARK HORSE COMICS',
                        creators: { writers: ['Mike Mignola', 'Scott Allie'], 
                                    artists: ['Sebastian Fiumara'], 
                                    cover_artists: ['cover_artist_1']},
                        preview: 'stuff happens',
                        suggested_price: '$3.99',
                        type: 'single_issue',
                        diamond_id: '11111',
                        shipping_date: Date.new(2016, 6, 8),
                        additional_info: {}
          }
          expect { db_saver.persist_to_db test_hash }.to change { Comic.count }.by(1)
        end
        
        context 'variant_cover' do
          before do
            Fabricate(:creator, name: 'cover_artist_2')
            Fabricate(:creator, name: 'cover_artist_3')
          end

          it 'associate cover_artist if it exists' do
            test_hash = {
                          title: 'SUPERMAN',
                          issue_number: '2',
                          publisher: 'DARK HORSE COMICS',
                          creators: { writers: ['Mike Mignola', 'Scott Allie'], 
                                      artists: ['Sebastian Fiumara'], 
                                      cover_artists: ['cover_artist_2', 'cover_artist_3']},
                          preview: 'stuff happens',
                          suggested_price: '$3.99',
                          type: 'single_issue',
                          diamond_id: '11111',
                          shipping_date: Date.new(2016, 6, 8),
                          additional_info: { variant_cover: true }
            }
            expect { db_saver.persist_to_db test_hash }.not_to change { Comic.count }
            comic = Comic.find_by diamond_code: '11111'
            expect(comic.cover_artists.map(&:name)).to include('cover_artist_2', 'cover_artist_3')
          end

          it 'creates and associated cover_artist if it doesnt exist' do
            test_hash = {
                          title: 'SUPERMAN',
                          issue_number: '2',
                          publisher: 'DARK HORSE COMICS',
                          creators: { writers: ['Mike Mignola', 'Scott Allie'], 
                                      artists: ['Sebastian Fiumara'], 
                                      cover_artists: ['cover_artist_4']},
                          preview: 'stuff happens',
                          suggested_price: '$3.99',
                          type: 'single_issue',
                          diamond_id: '11111',
                          shipping_date: Date.new(2016, 6, 8),
                          additional_info: { variant_cover: true }
            }
            creator_count_before = Creator.count
            expect { db_saver.persist_to_db test_hash }.not_to change { Comic.count }
            expect(creator_count_before).not_to eq(Creator.count)
            comic = Comic.find_by diamond_code: '11111'
            expect(comic.cover_artists.map(&:name)).to include('cover_artist_4')
          end

          it 'nothing if the artist already associated with the issue' do
            test_hash = {
                          title: 'SUPERMAN',
                          issue_number: '2',
                          publisher: 'DARK HORSE COMICS',
                          creators: { writers: [], 
                                      artists: [], 
                                      cover_artists: ['cover_artist_1']},
                          preview: 'stuff happens',
                          suggested_price: '$3.99',
                          type: 'single_issue',
                          diamond_id: '11111',
                          shipping_date: Date.new(2016, 6, 8),
                          additional_info: { variant_cover: true }
            }
            creator_count_before = Creator.count
            expect { db_saver.persist_to_db test_hash }.not_to change { Comic.count }
            expect(creator_count_before).to eq(Creator.count)
          end
        end
      end
    end

    context 'not a single issue' do
      before do
        Fabricate(:comic) do
          title 'SUPERMAN 69 HC VOL 2'
          item_type 'hardcover'
          diamond_code '2222'
        end
      end

      it 'saves if doesnt exist' do
        test_hash = {
                      title: 'SUPERMAN 69 HC VOL 3',
                      issue_number: '',
                      publisher: 'DARK HORSE COMICS',
                      creators: { writers: ['Mike Mignola', 'Scott Allie'], 
                                  artists: ['Sebastian Fiumara'], 
                                  cover_artists: ['cover_artist_1']},
                      preview: 'stuff happens',
                      suggested_price: '$3.99',
                      type: 'hardcover',
                      diamond_id: '11111',
                      shipping_date: Date.new(2016, 6, 8),
                      additional_info: {}
        }
        expect { db_saver.persist_to_db test_hash }.to change { Comic.count }.by(1)
      end

      it' doesnt save if already exists' do
        test_hash = {
                      title: 'SUPERMAN 69 HC VOL 2',
                      issue_number: '',
                      publisher: 'DARK HORSE COMICS',
                      creators: { writers: ['Mike Mignola', 'Scott Allie'], 
                                  artists: ['Sebastian Fiumara'], 
                                  cover_artists: ['cover_artist_1']},
                      preview: 'stuff happens',
                      suggested_price: '$3.99',
                      type: 'hardcover',
                      diamond_id: '11111',
                      shipping_date: Date.new(2016, 6, 8),
                      additional_info: {}
        }
        expect { db_saver.persist_to_db test_hash }.not_to change { Comic.count }
      end
    end
  end
end
