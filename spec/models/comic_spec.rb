require 'rails_helper'

RSpec.describe Comic, :type => :model do
  let(:comic) do
    Fabricate(:comic, title: 'SUPERMAN') do
      writers { [Fabricate(:creator, name: 'GEOFF JOHNS')] }
    end
  end

  it 'has working writers association' do
    expect(comic.writers.map &:name).to include('GEOFF JOHNS')
  end
end
