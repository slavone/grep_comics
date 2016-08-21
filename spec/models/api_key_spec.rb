require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  it 'generates a unique key' do
    expect {
      ApiKey.generate_new
    }.to change(ApiKey, :count).by(1)
    expect(ApiKey.first.key).not_to be_empty
  end

  it 'has unique key' do
    Fabricate(:api_key, key: '123')
    expect {
      ApiKey.create key: '123'
    }.not_to change(ApiKey, :count)
  end
end
