# == Schema Information
#
# Table name: api_keys
#
#  id         :integer          not null, primary key
#  key        :string
#  call_count :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ApiKey < ApplicationRecord
  validates :key, uniqueness: true

  def self.generate_new
    loop do
      new_key = SecureRandom.hex
      next if ApiKey.find_by key: new_key
      return ApiKey.create key: new_key
    end
  end
end
