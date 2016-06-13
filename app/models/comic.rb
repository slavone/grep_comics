# == Schema Information
#
# Table name: comics
#
#  id              :integer          not null, primary key
#  diamond_code    :string
#  title           :string
#  issue_number    :integer
#  preview         :text
#  suggested_price :decimal(, )
#  item_type       :string
#  shipping_date   :date
#  publisher_id    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cover_image     :string
#
# Foreign Keys
#
#  fk_rails_4c749ccbd2  (publisher_id => publishers.id)
#

class Comic < ApplicationRecord
  belongs_to :publisher
  has_many :writer_credits
  has_many :writers, through: :writer_credits, source: :creator
  has_many :artist_credits
  has_many :artists, through: :artist_credits, source: :creator
  has_many :cover_artist_credits
  has_many :cover_artists, through: :cover_artist_credits, source: :creator
end
