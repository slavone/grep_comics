require 'rails_helper'

RSpec.describe Comic, :type => :model do
  let(:comic) do
    Fabricate(:comic, title: 'SUPERMAN') do
      writers { [Fabricate(:creator, name: 'GEOFF JOHNS')] }
      artists { [Fabricate(:creator, name: 'FRANK QUITELY')] }
    end
  end

  it 'has writers' do
    expect(comic.writers.map &:name).to include('GEOFF JOHNS')
  end

  it 'has artists' do
    expect(comic.artists.map &:name).to include('FRANK QUITELY')
  end
end
