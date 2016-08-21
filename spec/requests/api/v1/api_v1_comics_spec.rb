require 'rails_helper'

RSpec.describe "Api::V1::Comics", type: :request do
  let(:titles) { ['Superman', 'Batman', 'Spider-Man', 'Rhino'] }
  let(:seed_comics) do
    weekly_list_1 = Fabricate(:weekly_list, wednesday_date: Date.new(2016, 6, 8) )
    weekly_list_2 = Fabricate(:weekly_list, wednesday_date: Date.new(2015, 6, 8) )

    titles.each_with_index do |comic_title, i|
      Fabricate(:comic) do
        diamond_code i
        title comic_title
        issue_number i
        reprint_number (i.even? ? i : false )
        is_variant (i.even? ? true : false )
        publisher { Fabricate(:publisher, name: "#{comic_title} PUBLISHER".upcase) }
        item_type (i.even? ? 'single_issue' : 'trade_paperback')
        writers { [Fabricate(:creator, name: "writer_#{i}")] }
        artists { [Fabricate(:creator, name: "artist_#{i}")] }
        cover_artists { [Fabricate(:creator, name: "cover_artist_#{i}")] }
        shipping_date (i.even? ? Date.new(2016, 6, 8) : Date.new(2015, 6, 8) )
        weekly_list { i.even? ? weekly_list_1 : weekly_list_2 }
      end
    end
  end

  describe "GET /api_v1_comics" do
    it "200 with format json" do
      get api_v1_comics_path(format: :json)
      expect(response).to have_http_status(200)
    end

    it "400 with other formats" do
      get api_v1_comics_path
      expect(response).to have_http_status(400)
    end

    it 'responds with the right schema' do
      Fabricate(:comic) do
        diamond_code '11111'
        title 'some comic'
        issue_number 2
        reprint_number 3
        item_type 'single_issue'
        writers { [Fabricate(:creator, name: 'writer')] }
        artists { [Fabricate(:creator, name: 'artist')] }
        cover_artists { [Fabricate(:creator, name: 'cover_artist')] }
        shipping_date Date.new(2016, 6, 8)
      end

      schema = {
        'total' => 1,
        'comics' => [{
          'diamond_code' => '11111',
          'title' => 'some comic',
          'type' => 'single_issue',
          'issue_number' => 2,
          'reprint_number' => 3,
          'preview' => 'Stuff happens',
          'original_cover_url' => 'cover_url.com',
          'publisher' => 'DC COMICS',
          'shipping_date' => '2016-06-08',
          'creators' => {
            'writers' => [{
              'name' => 'writer'
            }],
            'artists' => [{
              'name' => 'artist'
            }],
            'cover_artists' => [{
              'name' => 'cover_artist'
            }]
          }
        }]
      }

      get api_v1_comics_path(format: :json)
      @parsed_response = JSON.parse(response.body)
      expect(@parsed_response).to eq(schema)
    end

    context 'no params' do
      before do
        seed_comics
        get api_v1_comics_path(format: :json)
        @parsed_response = JSON.parse(response.body)
      end

      it 'responses with all comics, sorted by titles' do
        response_titles = @parsed_response['comics'].map { |comic| comic['title'] }
        expect(response_titles).to eq(titles.sort)
      end
    end

    context 'with params' do
      before do
        seed_comics
      end

      context 'publisher' do
        it 'filters by strict publisher name' do
          get api_v1_comics_path(format: :json, publisher: 'batman publisher')
          @parsed_response = JSON.parse(response.body)
          expect(@parsed_response['comics'].map { |c| c['title'] }).to include('Batman')
          expect(@parsed_response['comics'].map { |c| c['title'] }).not_to include('Superman')
        end
      end

      context 'title' do
        it 'filters by titles that are ILIKE queried string' do
          get api_v1_comics_path(format: :json, title: 'man')
          @parsed_response = JSON.parse(response.body)
          expect(@parsed_response['comics'].map { |c| c['title'] }).to include('Batman', 'Superman')
          expect(@parsed_response['comics'].map { |c| c['title'] }).not_to include('Rhino')
        end
      end

      context 'creators' do
        it 'displays comics that has any queried creators credited' do
          get api_v1_comics_path(format: :json, creators: 'writer_1, artist_2')
          @parsed_response = JSON.parse(response.body)
          creators_arr = @parsed_response['comics'].map do |comic|
            comic['creators'].map do |_, creators_a|
              creators_a.map { |creator| creator['name'] }
            end
          end.flatten
          expect(creators_arr).to include('writer_1', 'artist_2')
          expect(creators_arr).not_to include('writer_0', 'artist_3')
        end
      end

      context 'writers' do
        it 'displays comics that has any queried writers credited' do
          get api_v1_comics_path(format: :json, writers: 'writer_1, writer_2')
          @parsed_response = JSON.parse(response.body)
          creators_arr = @parsed_response['comics'].map do |comic|
            comic['creators'].map do |_, creators_a|
              creators_a.map { |creator| creator['name'] }
            end
          end.flatten
          expect(creators_arr).to include('writer_1', 'writer_2')
          expect(creators_arr).not_to include('writer_0', 'writer_3')
        end
      end

      context 'artists' do
        it 'displays comics that has any queried artists credited' do
          get api_v1_comics_path(format: :json, artists: 'artist_1, artist_2')
          @parsed_response = JSON.parse(response.body)
          creators_arr = @parsed_response['comics'].map do |comic|
            comic['creators'].map do |_, creators_a|
              creators_a.map { |creator| creator['name'] }
            end
          end.flatten
          expect(creators_arr).to include('artist_1', 'artist_2')
          expect(creators_arr).not_to include('artist_0', 'artist_3')
        end
      end

      context 'cover_artists' do
        it 'displays comics that has any queried cover_artists credited' do
          get api_v1_comics_path(format: :json, cover_artists: 'cover_artist_1, cover_artist_3')
          @parsed_response = JSON.parse(response.body)
          creators_arr = @parsed_response['comics'].map do |comic|
            comic['creators'].map do |_, creators_a|
              creators_a.map { |creator| creator['name'] }
            end
          end.flatten
          expect(creators_arr).to include('cover_artist_1', 'cover_artist_3')
          expect(creators_arr).not_to include('cover_artist_0', 'cover_artist_2')
        end
      end

      context 'shipping_date' do
        it 'filters by shipping date' do
          queried_date, wrong_date = '2016-06-08', '2015-06-08'
          get api_v1_comics_path(format: :json, shipping_date: queried_date)
          @parsed_response = JSON.parse(response.body)
          expect(@parsed_response['comics'].map { |c| c['shipping_date'] }).to include(queried_date)
          expect(@parsed_response['comics'].map { |c| c['shipping_date'] }).not_to include(wrong_date)
        end
      end

      context 'has_variant_covers' do
        it 'filters to only comics that have variant covers' do
          get api_v1_comics_path(format: :json, has_variant_covers: true)
          @parsed_response = JSON.parse(response.body)
          expect(@parsed_response['comics'].map { |c| c['has_variant_covers'] }).to include(true)
          expect(@parsed_response['comics'].map { |c| c['has_variant_covers'] }).not_to include(false, nil)
        end

        it 'doesnt crash if its not true' do
          get api_v1_comics_path(format: :json, has_variant_covers: 'fasdasdsadsad')
          @parsed_response = JSON.parse(response.body)
          expect(@parsed_response['comics'].size).to eq(titles.size)
        end
      end

      context 'issue_number' do
        it 'filters by issue number' do
          get api_v1_comics_path(format: :json, issue_number: 2)
          @parsed_response = JSON.parse(response.body)
          expect(@parsed_response['comics'].map { |c| c['issue_number'] }).to include(2)
          expect(@parsed_response['comics'].map { |c| c['issue_number'] }).not_to include(1, 3, 4)
        end
      end

      context 'reprint' do
        it 'filters to only comics that are reprints' do
          get api_v1_comics_path(format: :json, reprint: true)
          @parsed_response = JSON.parse(response.body)
          expect(@parsed_response['comics'].map { |c| c['reprint_number'] }).not_to include(false, nil)
        end
      end

      context 'type' do
        it 'filters by item_type' do
          get api_v1_comics_path(format: :json, type: 'single_issue')
          @parsed_response = JSON.parse(response.body)
          expect(@parsed_response['comics'].map { |c| c['type'] }).to include('single_issue')
          expect(@parsed_response['comics'].map { |c| c['type'] }).not_to include('trade_paperback')
        end
      end
    end
  end

  describe "GET /api_v1_weekly_releases" do
    it "200 with format json" do
      get api_v1_weekly_releases_path(format: :json, date: '10-10-2014')
      expect(response).to have_http_status(200)
    end

    it "400 with other formats" do
      get api_v1_weekly_releases_path
      expect(response).to have_http_status(400)
    end

    it 'responds with the same schema as api/v1/comics' do
      Fabricate(:comic) do
        diamond_code '11111'
        title 'some comic'
        issue_number 2
        reprint_number 3
        item_type 'single_issue'
        writers { [Fabricate(:creator, name: 'writer')] }
        artists { [Fabricate(:creator, name: 'artist')] }
        cover_artists { [Fabricate(:creator, name: 'cover_artist')] }
        shipping_date Date.new(2016, 6, 8)
      end

      schema = {
        'total' => 1,
        'comics' => [{
          'diamond_code' => '11111',
          'title' => 'some comic',
          'type' => 'single_issue',
          'issue_number' => 2,
          'reprint_number' => 3,
          'preview' => 'Stuff happens',
          'original_cover_url' => 'cover_url.com',
          'publisher' => 'DC COMICS',
          'shipping_date' => '2016-06-08',
          'creators' => {
            'writers' => [{
              'name' => 'writer'
            }],
            'artists' => [{
              'name' => 'artist'
            }],
            'cover_artists' => [{
              'name' => 'cover_artist'
            }]
          }
        }]
      }

      get api_v1_weekly_releases_path(format: :json, date: '06-08-2016')
      @parsed_response = JSON.parse(response.body)
      expect(@parsed_response).to eq(schema)
    end

    context 'no params' do
      it "400, requires date" do
        get api_v1_weekly_releases_path(format: :json)
        expect(response).to have_http_status(400)
      end
    end

    context 'with params' do
      before do
        seed_comics
      end

      context 'date' do
        it 'only returns comics, associated with the weekly list' do
          get api_v1_weekly_releases_path(format: :json, date: '2016-06-08')
          @parsed_response = JSON.parse(response.body)

          expect(@parsed_response['comics'].map { |c| Date.parse c['shipping_date'] }).to include(Date.parse '2016-06-08')
          expect(@parsed_response['comics'].map { |c| Date.parse c['shipping_date'] }).not_to include(Date.parse '2015-06-08')
        end
      end

      context 'creators' do
        it 'displays comics that has any queried creators credited' do
          get api_v1_weekly_releases_path(format: :json, date: '2016-06-08', creators: 'writer_1, artist_2')
          @parsed_response = JSON.parse(response.body)
          creators_arr = @parsed_response['comics'].map do |comic|
            comic['creators'].map do |_, creators_a|
              creators_a.map { |creator| creator['name'] }
            end
          end.flatten
          expect(creators_arr).to include('artist_2')
          expect(creators_arr).not_to include('writer_0', 'writer_1', 'artist_3')
        end
      end

    end

  end
end
