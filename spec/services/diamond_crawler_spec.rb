require 'rails_helper'

RSpec.describe DiamondCrawler do
  let(:crawler) { DiamondCrawler.new }
  let(:test_page) do
    'New Releases For 8/17/2016
    
    DARK HORSE COMICS
    
    APR160059 ALIENS DEFIANCE #3  $3.99
    APR160124 BIRD BOY TP VOL 02 LIMINAL WOOD $9.99
    JUN160036 BLACK HAMMER #2 $3.99
    JUN160037 BLACK HAMMER #2 LEMIRE VAR CVR  $3.99
    JUN160100 BPRD HELL ON EARTH #144 $3.99
    JUN160011 BRIGGS LAND #1  $3.99
    APR160092 CREEPY ARCHIVES HC VOL 24 $49.99
    JUN160041 DARK HORSE PRESENTS 2014 #25  $4.99
    APR160153 NGE SHINJI IKARI RAISING PROJECT OMNIBUS TP VOL 01  $19.99
    APR160131 POLAR HC VOL 03 NO MERCY FOR SISTER MARIA $17.99'
  end


  it 'returns an array of diamond_codes from page' do
    parsed_arr = ['APR160059', 'APR160124', 'JUN160036', 'JUN160037', 'JUN160100', 'JUN160011', 'APR160092', 'JUN160041', 'APR160153', 'APR160131']
    expect(crawler.send(:comics_diamond_ids, test_page)).to eq(parsed_arr)
  end

  it 'return correct date' do
    expect(crawler.send(:listed_date, test_page)).to eq(Date.new 2016, 8, 17)
  end

  context 'weekly_list with the date from the list doesnt exist' do
    before do
      @date = Date.new(2016, 8, 17)
    end

    it 'creates new' do
      expect(crawler.send(:set_weekly_list!, 
                          @date,
                          test_page)).to eq(WeeklyList.find_by(wednesday_date: @date))
    end
  end

  context 'weekly_list with the date already exists' do
    before do
      @date = Date.new(2016, 8, 17)
      crawler.send(:set_weekly_list!, @date, test_page)
    end

    it 'doest set weekly_list if page didnt change' do
      expect {
        crawler.send(:set_weekly_list!, @date, test_page)
      }.not_to change { WeeklyList.count }
      expect(crawler.send(:set_weekly_list!, 
                          @date,
                          test_page)).to eq(nil)
    end

    it 'updates the page of persisted list if it changed' do
      changed_page = test_page + 'some changes'
      expect {
        crawler.send(:set_weekly_list!, @date, changed_page)
      }.to change { WeeklyList.find_by(wednesday_date: @date).list }
    end

    it 'overwrites the page and sets the list no matter what if options[:overwrite]' do
      options = { overwrite: true }
      expect(crawler.send(:set_weekly_list!, @date, test_page, options)).to eq(WeeklyList.find_by(wednesday_date: @date))
    end

  end

  context 'mutated crawler with stubbed page' do
    before do
      @mutated_crawler = crawler
      allow(@mutated_crawler.instance_variable_get :@parser).to receive(:get_page) { test_page }
    end
  end
end

