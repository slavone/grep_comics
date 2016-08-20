require 'rails_helper'

RSpec.describe "Api::V1::Creators", type: :request do
  let(:creators_list) do
    ['Mike Mignola', 'Grant Morrison', 'Michael DeForge']
  end

  describe "GET /api_v1_creators" do
    before do
      creators_list.each do |creator_name|
        Fabricate(:creator, name: creator_name)
      end
    end

    it "200 with format json" do
      get api_v1_creators_path(format: :json)
      expect(response).to have_http_status(200)
    end

    it "400 with other formats" do
      get api_v1_creators_path
      expect(response).to have_http_status(400)
    end

    it 'responds with the right schema' do
      get api_v1_creators_path(format: :json)
      schema = {
        'total' => 3,
        'creators' => creators_list.sort.map do |name|
          {
            'name' => name,
            'totalWriterCredits' => 0,
            'totalArtistCredits' => 0,
            'totalCoverArtistCredits' => 0
          }
        end
      }
      @parsed_response = JSON.parse(response.body)
      expect(@parsed_response).to eq(schema)
    end

    context 'no params' do
      before do
        get api_v1_creators_path(format: :json)
        @parsed_response = JSON.parse(response.body)
      end

      it "returns full list" do
        expect(@parsed_response['total']).to eq(3)
      end

      it 'ordered by asc name' do
        expect(@parsed_response['creators'].map { |e| e['name'] }).to eq(creators_list.sort)
      end
    end

    context 'with params' do
      context 'names' do
        it 'filters by name' do
          get api_v1_creators_path(format: :json, names: 'GRANT,mich')
          @parsed_response = JSON.parse(response.body)
          expect(@parsed_response['total']).to eq(2)
          expect(@parsed_response['creators'].map { |e| e['name'] }).to eq(['Grant Morrison', 'Michael DeForge'])
        end

        it 'case insensitive' do
          get api_v1_creators_path(format: :json, names: 'GRANT')
          response_upcase = response.body
          get api_v1_creators_path(format: :json, names: 'grant')
          response_downcase = response.body
          expect(response_upcase).to eq(response_downcase)
        end
      end
    end
  end

  describe "GET /api_v1_creator" do
    before do
      creators_list.each do |creator_name|
        Fabricate(:creator, name: creator_name)
      end
    end

    it "400 unless format json" do
      get api_v1_creator_path(name: 'adad')
      expect(response).to have_http_status(400)
    end

    context 'no params' do
      it '400 - wrong query params' do
        get api_v1_creator_path(format: :json)
        expect(response).to have_http_status(400)
      end
    end

    it 'responds with the right schema' do
      get api_v1_creator_path(format: :json, name: 'Michael')
      schema = {
        'name' => 'Michael DeForge',
        'drawnComics' => [],
        'drawnCovers' => [],
        'writtenComics' => [],
        'workedForPublishers' => []
      }
      @parsed_response = JSON.parse(response.body)
      expect(@parsed_response).to eq(schema)
    end

    context 'with params' do
      context 'name' do
        it 'finds by name' do
          get api_v1_creator_path(format: :json, name: 'Michael')
          @parsed_response = JSON.parse(response.body)
          expect(@parsed_response['name']).to eq('Michael DeForge')
        end

        it 'case insensitive' do
          get api_v1_creator_path(format: :json, name: 'michael')
          response_upcase = response.body
          get api_v1_creator_path(format: :json, name: 'MICHAEL')
          response_downcase = response.body
          expect(response_upcase).to eq(response_downcase)
        end
      end
    end

  end
end
