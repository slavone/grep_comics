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
  has_many :artist_credits
  has_many :comics_as_artist, through: :artist_credits, source: :comic
  has_many :cover_artist_credits
  has_many :comics_as_cover_artist, through: :cover_artist_credits, source: :comic

  def worked_for_publishers
    Publisher.find_by_sql "SELECT DISTINCT publishers.*
                          FROM comics JOIN publishers
                          ON comics.publisher_id = publishers.id
                          WHERE comics.id IN (
                            SELECT writer_credits.comic_id
                            FROM writer_credits
                            WHERE writer_credits.creator_id = #{self.id}
                            UNION ALL
                            SELECT artist_credits.comic_id
                            FROM artist_credits
                            WHERE artist_credits.creator_id = #{self.id}
                            UNION ALL
                            SELECT cover_artist_credits.comic_id
                            FROM cover_artist_credits
                            WHERE cover_artist_credits.creator_id = #{self.id}
                          )
                          ORDER BY publishers.name"
  end
end
