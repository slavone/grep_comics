# == Schema Information
#
# Table name: creator_credits
#
#  id          :integer          not null, primary key
#  creator_id  :integer
#  comic_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  credited_as :enum
#
# Foreign Keys
#
#  fk_rails_51059dd044  (comic_id => comics.id)
#

class CreatorCredit < ApplicationRecord
  belongs_to :comic
  belongs_to :creator
end
