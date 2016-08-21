require 'rails_helper'

RSpec.describe "Api::V1::Publishers", type: :request do
  let(:api_key) { ApiKey.generate_new.key }

  describe "GET /api_v1_publishers" do
    let(:publishers_list) do
      ['DARK HORSE COMICS', 'MARVEL COMICS', 'FANTAGRAPHICS',
       'KOYAMA PRESS', 'DC COMICS']
    end

    before do
      publishers_list.each do |publisher|
        Fabricate(:publisher, name: publisher )
      end
    end

    it "200 with format json" do
      get api_v1_publishers_path(format: :json, key: api_key)
      expect(response).to have_http_status(200)
    end

    it "400 with other formats" do
      get api_v1_publishers_path(key: api_key)
      expect(response).to have_http_status(400)
    end

    it "401 unless key provided" do
      get api_v1_publishers_path
      expect(response).to have_http_status(401)
    end

    it 'responds with the right schema' do
      get api_v1_publishers_path(format: :json, key: api_key)
      schema = {
        'total' => 5,
        'publishers' => publishers_list.sort.map do |name|
          {
            'name' => name,
            'total_comics' => 0
          }
        end
      }
      @parsed_response = JSON.parse(response.body)
      expect(@parsed_response).to eq(schema)
    end

    context 'no params' do
      before do
        get api_v1_publishers_path(format: :json, key: api_key)
        @parsed_response = JSON.parse(response.body)
      end

      it "returns full list" do
        expect(@parsed_response['total']).to eq(5)
      end

      it 'ordered by asc name' do
        expect(@parsed_response['publishers'].map { |e| e['name'] }).to eq(publishers_list.sort)
      end
    end

    context 'with params' do
      it 'names' do
        get api_v1_publishers_path(format: :json, names: 'dark,marvel', key: api_key)
        @parsed_response = JSON.parse(response.body)
        expect(@parsed_response['total']).to eq(2)
        expect(@parsed_response['publishers'].map { |e| e['name'] }).to eq(['DARK HORSE COMICS', 'MARVEL COMICS'])
      end
    end
  end
end
