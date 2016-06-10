require 'rails_helper'

RSpec.describe Publisher, :type => :model do
  let(:publisher) { Fabricate :publisher }

  it 'has comics association' do
    expect(publisher.comics.class).to eq(Comic::ActiveRecord_Associations_CollectionProxy)
  end
end
