require 'rails_helper'

RSpec.describe "Api::V1::Publishers", type: :request do
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
      get api_v1_publishers_path(format: :json)
      expect(response).to have_http_status(200)
    end

    it "400 with other formats" do
      get api_v1_publishers_path
      expect(response).to have_http_status(400)
    end

    it 'responds with schema' do
      get api_v1_publishers_path(format: :json)
      schema = {
        'total' => 5,
        'publishers' => publishers_list.sort.map { |name| { 'name' => name, 'total_comics' => 0 } }
      }
      @parsed_response = JSON.parse(response.body)
      expect(@parsed_response).to eq(schema)
    end

    context 'no params' do
      before do
        get api_v1_publishers_path(format: :json)
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
      it 'returns by name' do
        get api_v1_publishers_path(format: :json, names: 'dark,marvel')
        @parsed_response = JSON.parse(response.body)
        puts @parsed_response.inspect
        expect(@parsed_response['total']).to eq(2)
        expect(@parsed_response['publishers'].map { |e| e['name'] }).to eq(['DARK HORSE COMICS', 'MARVEL COMICS'])
      end
    end
  end
end
