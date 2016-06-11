# == Schema Information
#
# Table name: artist_credits
#
#  id         :integer          not null, primary key
#  creator_id :integer
#  comic_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Foreign Keys
#
#  fk_rails_239a242689  (creator_id => creators.id)
#  fk_rails_c88ce77b6a  (comic_id => comics.id)
#

class ArtistCredit < ApplicationRecord
  belongs_to :creator
  belongs_to :comic
end
