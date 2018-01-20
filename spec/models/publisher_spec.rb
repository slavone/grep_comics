require 'rails_helper'

RSpec.describe Publisher, :type => :model do
  let(:publisher) { Fabricate :publisher }

  it 'has comics association' do
    expect(Publisher.reflect_on_association(:comics).macro).to eq(:has_many)
  end
end
