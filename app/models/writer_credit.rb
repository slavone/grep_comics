# == Schema Information
#
# Table name: writer_credits
#
#  id         :integer          not null, primary key
#  creator_id :integer
#  comic_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Foreign Keys
#
#  fk_rails_1327a9360d  (comic_id => comics.id)
#  fk_rails_af086b60d2  (creator_id => creators.id)
#

class WriterCredit < ApplicationRecord
  belongs_to :comic
  belongs_to :creator
end
