# == Schema Information
#
# Table name: cover_artist_credits
#
#  id         :integer          not null, primary key
#  creator_id :integer
#  comic_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Foreign Keys
#
#  fk_rails_3a1f2eaf5a  (comic_id => comics.id)
#  fk_rails_d036e92763  (creator_id => creators.id)
#

class CoverArtistCredit < ApplicationRecord
  belongs_to :creator
  belongs_to :comic
end
