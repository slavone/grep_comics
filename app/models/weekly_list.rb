# == Schema Information
#
# Table name: weekly_lists
#
#  id             :integer          not null, primary key
#  list           :text
#  wednesday_date :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class WeeklyList < ApplicationRecord
  has_many :comics

  class << self
    def current_week_list
      WeeklyList.order(wednesday_date: :desc).first
    end
  end

  def fetch_comics
    self.comics.eager_load(:publisher).preload(:writers, :artists, :cover_artists).order('publishers.name', :title, :issue_number)
  end

  def all_creators
    Creator.find_by_sql("WITH weekly_comics AS (
                        SELECT id FROM comics WHERE weekly_list_id = #{self.id}
                        )
                        SELECT DISTINCT *
                        FROM creators
                        WHERE
                        id IN (
                          SELECT writer_credits.creator_id
                          FROM writer_credits JOIN weekly_comics 
                          ON writer_credits.comic_id = weekly_comics.id
                          UNION ALL
                          SELECT artist_credits.creator_id
                          FROM artist_credits JOIN weekly_comics 
                          ON artist_credits.comic_id = weekly_comics.id
                          UNION ALL
                          SELECT cover_artist_credits.creator_id
                          FROM cover_artist_credits JOIN weekly_comics 
                          ON cover_artist_credits.comic_id = weekly_comics.id
                        )
                        ORDER BY name")
  end
end
