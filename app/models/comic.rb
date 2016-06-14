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
#  weekly_list_id  :integer
#
# Foreign Keys
#
#  fk_rails_4c749ccbd2  (publisher_id => publishers.id)
#  fk_rails_812b74135e  (weekly_list_id => weekly_lists.id)
#

class Comic < ApplicationRecord
  belongs_to :publisher
  belongs_to :weekly_list, optional: true
  has_many :writer_credits
  has_many :writers, through: :writer_credits, source: :creator
  has_many :artist_credits
  has_many :artists, through: :artist_credits, source: :creator
  has_many :cover_artist_credits
  has_many :cover_artists, through: :cover_artist_credits, source: :creator

  def humanized_title
    "#{title} #{'#' + issue_number.to_s if item_type == 'single_issue' }".strip
  end
end
