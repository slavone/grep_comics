require 'rails_helper'

RSpec.describe DiamondCrawler do
  it 'doesnt crash' do
    expect(DiamondCrawler).not_to eq(false)
  end
end
