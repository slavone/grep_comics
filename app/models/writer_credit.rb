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

class WriterCredit < ApplicationRecord
  belongs_to :comic
  belongs_to :creator
end
