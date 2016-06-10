require 'rails_helper'

RSpec.describe Creator, :type => :model do
  let(:creator) do
    Fabricate(:creator, name: 'some guy')
  end

  it 'has comics as writer' do
    Fabricate(:comic, writers: [creator], title: 'SUPERMAN')
    expect(creator.comics_as_writer.map &:title).to include('SUPERMAN')
  end
end
