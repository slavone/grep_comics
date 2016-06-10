# == Schema Information
#
# Table name: creators
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Creator < ApplicationRecord
  has_many :writer_credits
  has_many :comics_as_writer, through: :writer_credits, source: :comic
end
