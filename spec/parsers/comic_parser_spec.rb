require "spec_helper"
require 'diamond_comics_parser'
require 'open-uri'
require 'net/http'
require 'nokogiri'

RSpec.describe DiamondComicsParser do
  let(:parser) { DiamondComicsParser.new }
  let(:test_url) { 'samples/newreleases.txt' }
  let(:previews_page) { File.read(test_url) }
  let(:comic_page) { File.read('samples/APR160066.html') }

  it "correctly parses wednesday date" do
    expect(parser.parse_wednesday_date(previews_page)).to eq(Date.new 2016, 6, 8)
  end

  it "parses codes" do
    expect(parser.parse_diamond_codes(previews_page)).to include('APR160066', 'FEB160013', 'MAR160268')
  end

  it "parses only premier publishers and comics & graphic novels sections" do
    expect(parser.parse_diamond_codes(previews_page)).not_to include('FEB162183', 'FEB162822')
  end

  context 'parses comic info' do
    before do
      @noko_doc = Nokogiri::HTML(comic_page).css('.StockCode')
    end

    it 'title and number from description' do 
      expect(parser.parse_description(@noko_doc)).to eq(['ABE SAPIEN', '34'])
    end

    it 'publisher name' do
      expect(parser.parse_publisher(@noko_doc)).to eq('DARK HORSE COMICS')
    end

    context 'creator names' do
      it 'when (W) (A) (CA)' do
        div = '<div class="StockCodeCreators">(W) Mike Mignola, Scott Allie (A) Sebastian Fiumara (CA) Frank Quitely</div>'
        @noko_doc = Nokogiri::HTML(div)
        expect(parser.parse_creators(@noko_doc)).to eq({ writers: ['Mike Mignola', 'Scott Allie'], 
                                                         artists: ['Sebastian Fiumara'], 
                                                         cover_artists: ['Frank Quitely'] })
      end

      it 'when (W/A) and (CA)' do
        div = '<div class="StockCodeCreators">(W/A) Mike Mignola, Scott Allie  (CA) Frank Quitely</div>'
        @noko_doc = Nokogiri::HTML(div)
        expect(parser.parse_creators(@noko_doc)).to eq({ writers: ['Mike Mignola', 'Scott Allie'], 
                                                         artists: ['Mike Mignola', 'Scott Allie'], 
                                                         cover_artists: ['Frank Quitely'] })
      end

      it 'when (W/A/CA)' do
        div = '<div class="StockCodeCreators">(W/A/CA) Mike Mignola, Scott Allie, Frank Quitely</div>'
        @noko_doc = Nokogiri::HTML(div)
        expect(parser.parse_creators(@noko_doc)).to eq({ writers: ['Mike Mignola', 'Scott Allie', 'Frank Quitely'], 
                                                         artists: ['Mike Mignola', 'Scott Allie', 'Frank Quitely'], 
                                                         cover_artists: ['Mike Mignola', 'Scott Allie', 'Frank Quitely'] })
      end

      it 'when (W) and (A/CA)' do
        expect(parser.parse_creators(@noko_doc)).to eq({ writers: ['Mike Mignola', 'Scott Allie'], 
                                                         artists: ['Sebastian Fiumara'], 
                                                         cover_artists: ['Sebastian Fiumara'] })
      end
    end

    it 'preview' do
      expect(parser.parse_preview(@noko_doc)).to include('In this standalone story, Abe seeks answers in his most crucial and secret place of origin, where his destiny is revealed.')
    end

    it 'suggested price' do
        expect(parser.parse_suggested_price(@noko_doc)).to eq('$3.99')
    end
  end

  it 'builds correct hash from parsed page' do
    expect(parser.parse_comic_info(comic_page)).to eq({ title: 'ABE SAPIEN',
                                                        issue_number: '34',
                                                        publisher: 'DARK HORSE COMICS',
                                                        creators: { writers: ['Mike Mignola', 'Scott Allie'], artists: ['Sebastian Fiumara'], cover_artists: ['Sebastian Fiumara']},
                                                        preview: 'In this standalone story, Abe seeks answers in his most crucial and secret place of origin, where his destiny is revealed.',
                                                        suggested_price: '$3.99'
    })
  end
end
