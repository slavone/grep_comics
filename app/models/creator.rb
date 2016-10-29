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
  include CreatorCredits
  has_many :comics_as_writer, through: :writer_credits, source: :comic
  has_many :comics_as_artist, through: :artist_credits, source: :comic
  has_many :comics_as_cover_artist, through: :cover_artist_credits, source: :comic

  def worked_for_publishers
    Publisher.find_by_sql "SELECT DISTINCT publishers.*
                          FROM comics
                          JOIN publishers ON comics.publisher_id = publishers.id
                          JOIN creator_credits ON creator_credits.creator_id = #{self.id}
                          ORDER BY publishers.name"
  end
end
