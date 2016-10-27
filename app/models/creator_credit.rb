class CreatorCredit < ApplicationRecord
  belongs_to :comic
  belongs_to :creator
end
