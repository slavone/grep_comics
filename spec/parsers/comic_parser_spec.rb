require "rails_helper"

RSpec.describe DiamondComicsParser do
  let(:parser) { DiamondComicsParser.new }
  let(:test_url) { 'samples/newreleases.txt' }
  let(:previews_page) { File.read(test_url) }
  let(:comic_page) { File.read('samples/APR160066.html') }

  context 'parses weekly releases list' do
    it "wednesday date" do
      expect(parser.parse_wednesday_date(previews_page)).to eq(Date.new 2016, 6, 8)
    end

    context 'only comics codes' do
      it "diamond codes" do
        expect(parser.parse_diamond_codes(previews_page, :comics)).to include('APR160066', 'FEB160013', 'MAR160268')
      end

      it "only premier publishers and comics & graphic novels sections" do
        expect(parser.parse_diamond_codes(previews_page, :comics)).not_to include('FEB162183', 'FEB162822')
      end

      it 'doesnt include codes for things that arent comics' do
        expect(parser.parse_diamond_codes(previews_page, :comics)).not_to include('JUN150355', 'DEC150623', 'FEB160722')
      end
    end

    context 'all codes' do
      it 'codes from all sections' do
        expect(parser.parse_diamond_codes(previews_page)).to include('APR160419', 'JUN150355', 'FEB162944')
      end
    end

    context 'only merch' do
      it 'includes merch codes' do
        expect(parser.parse_diamond_codes(previews_page, :merchandise)).to include('JUN150355', 'FEB162944')
      end

      it 'doesnt include comics codes' do
        expect(parser.parse_diamond_codes(previews_page, :merchandise)).not_to include('APR160066', 'APR160979', 'FEB161065')
      end
    end
  end

  context 'parses comic info' do
    before do
      @noko_doc = Nokogiri::HTML(comic_page)
    end

    context 'description block' do
      it 'title of single issue' do
        expect(parser.parse_title(@noko_doc)).to eq('ABE SAPIEN')
      end

      #it 'titles of trades' do
      #  title_divs = ['<div class="StockCodeDescription">ART OF DOOM HC</div>',
      #                '<div class="StockCodeDescription">NEW LONE WOLF AND CUB TP VOL 09 (MR)</div>',
      #                '<div class="StockCodeDescription">KUROSAGI CORPSE DELIVERY SERVICE OMNIBUS ED TP BOOK 04</div>',
      #                '<div class="StockCodeDescription">SUPERMAN WONDER WOMAN TP VOL 03 CASUALTIES OF WAR</div>']
      #  title_divs.each do |doc|
      #  end
      #end

      it 'issue_number' do
        expect(parser.parse_issue_number(@noko_doc)).to eq('34')
      end

      it 'additional info' do
        desc = 'SUPERMAN TP VOL 03 CASUALTIES OF WAR CVR A 2ND PTG (MR)'
        expect(parser.build_additional_info(desc)).to eq({ variant_cover: true,
                                                               vol: '03',
                                                               reprint_number: '2',
                                                               mature_rating: true
                                                               
        })
      end

      context 'identifies types' do
        it 'hardcover' do
          descriptions = ['ART OF MIRRORS EDGE CATALYST HC', 
                          'SUPERMAN WONDER WOMAN HC VOL 04 DARK TRUTH']
          descriptions.each do |desc|
            expect(parser.identify_item_type(desc)).to eq 'hardcover'
          end
        end


        it 'softcover' do
          descriptions = ['WARHAMMER DEATH OF THE OLD WORLD SC', 
                          'SOME COMIC SC VOL 1']
          descriptions.each do |desc|
            expect(parser.identify_item_type(desc)).to eq 'softcover'
          end
        end
        
        it 'single_issue' do
          descriptions = ['ACTION COMICS #957', 
                          'INJECTION #10 CVR A SHALVEY & BELLAIRE (MR)',
                          'BIG TROUBLE IN LITTLE CHINA #25 (NOTE PRICE)']
          descriptions.each do |desc|
            expect(parser.identify_item_type(desc)).to eq 'single_issue'
          end
        end

        it 'trade_paperback' do
          descriptions = ['HERCULES TP VOL 01 STILL GOING STRONG', 
                          'NEW LONE WOLF AND CUB TP VOL 09 (MR)',
                          'DANGER GIRL PERMISSION TO THRILL COLORING BOOK TP']
          descriptions.each do |desc|
            expect(parser.identify_item_type(desc)).to eq 'trade_paperback'
          end
        end

        it 'graphic_novel' do
          descriptions = ['WARCRAFT BONDS OF BROTHERHOOD OGN', 
                          'DEADBEAT GN',
                          'THE UNIQUES GN VOL 01 COME TOGETHER']
          descriptions.each do |desc|
            expect(parser.identify_item_type(desc)).to eq 'graphic_novel'
          end
        end

        it 'merch and other stuff' do
          descriptions = ['HALO 5 GUARDIANS BEST OF AF', 
                          'BATMAN BLACK & WHITE STATUE DAVE MAZZUCCHELLI 2ND ED',
                          'AOD NECRONOMICON PX ZIP HOODIE XXL',
                          'CIVIL WAR II #1 BY DJURDJEVIC POSTER']
          descriptions.each do |desc|
            expect(parser.identify_item_type(desc)).to eq 'merchandise'
          end
        end

        it 'correctly if title has hc sc tp gn in it' do
          expect(parser.identify_item_type('SCHOOL OF ROCK HC')).to eq 'hardcover'
          expect(parser.identify_item_type('SCP-325 TP')).to eq 'trade_paperback'
          expect(parser.identify_item_type('SCHOOL OF ROCK #420')).to eq 'single_issue'
          expect(parser.identify_item_type('ADVENTURES OF GNOMES SC')).to eq 'softcover'
        end
      end
    end


    it 'cover image' do
      expect(parser.parse_cover_image(@noko_doc)).to eq('http://www.previewsworld.com/catalogimages/STK_IMAGES/STL000001-020000/STL006317.jpg')
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

      it 'when unexpected symbols in creator names' do
        div = '<div class="StockCodeCreators">(W) Peter J. Tomasi (A) Doug Mahnke & Various (CA) Doug Mahnke, Mœbius</div>'
        @noko_doc = Nokogiri::HTML(div)
        expect(parser.parse_creators(@noko_doc)).to eq({ writers: ['Peter J. Tomasi'], 
                                                         artists: ['Doug Mahnke'], 
                                                         cover_artists: ['Doug Mahnke', 'Mœbius'] })
      end

      it 'when there is no writer' do
        div = '<div class="StockCodeCreators">(A/CA) J. Scott Campbell</div>'
        @noko_doc = Nokogiri::HTML(div)
        expect(parser.parse_creators(@noko_doc)).to eq({ writers: [], 
                                                         artists: ['J. Scott Campbell'], 
                                                         cover_artists: ['J. Scott Campbell'] })
      end

      it 'only writer' do
        div = '<div class="StockCodeCreators">(W) Grant Morrison</div>'
        @noko_doc = Nokogiri::HTML(div)
        expect(parser.parse_creators(@noko_doc)).to eq({ writers: ['Grant Morrison'], 
                                                         artists: [], 
                                                         cover_artists: [] })
      end

    end

    it 'preview' do
      expect(parser.parse_preview(@noko_doc)).to include('In this standalone story, Abe seeks answers in his most crucial and secret place of origin, where his destiny is revealed.')
    end

    it 'diamond_id' do
      expect(parser.parse_diamond_id(@noko_doc)).to eq('APR160066')
    end

    it 'suggested price' do
      expect(parser.parse_suggested_price(@noko_doc)).to eq('$3.99')
    end

    it 'shipping date' do
      expect(parser.parse_shipping_date(@noko_doc)).to eq(Date.new 2016, 6, 8)
    end


  end

  it 'builds correct hash from parsed page' do
    expect(parser.parse_comic_info(comic_page)).to eq({ title: 'ABE SAPIEN',
                                                        issue_number: '34',
                                                        publisher: 'DARK HORSE COMICS',
                                                        creators: { writers: ['Mike Mignola', 'Scott Allie'], artists: ['Sebastian Fiumara'], cover_artists: ['Sebastian Fiumara']},
                                                        preview: 'In this standalone story, Abe seeks answers in his most crucial and secret place of origin, where his destiny is revealed.',
                                                        suggested_price: '$3.99',
                                                        type: 'single_issue',
                                                        diamond_id: 'APR160066',
                                                        shipping_date: Date.new(2016, 6, 8),
                                                        additional_info: {},
                                                        cover_image_url: 'http://www.previewsworld.com/catalogimages/STK_IMAGES/STL000001-020000/STL006317.jpg'
    })
  end
end
