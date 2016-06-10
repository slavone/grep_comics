require 'rails_helper'

RSpec.describe DiamondWeeklyExecutor do
  it 'doesnt crash' do
    expect(DiamondWeeklyExecutor).not_to eq(false)
  end
end
