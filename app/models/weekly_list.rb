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
  has_many :comics, dependent: :destroy
  has_many :comics_with_no_covers, -> { where no_cover_available: true }, class_name: 'Comic'

  class << self
    def earliest_wednesday_date
      WeeklyList.order(:wednesday_date).limit(1).pluck(:wednesday_date).first
    end

    def current_week_list
      WeeklyList.order(wednesday_date: :desc).first
    end

    def find_by_closest_date(date)
      sanitized_date = Date.parse date

      WeeklyList.order("abs(wednesday_date - date '#{sanitized_date}')").first
    end
  end

  def fetch_comics
    self.comics.eager_load(:publisher)
               .preload(:writers, :artists, :cover_artists)
               .order('publishers.name', :title, :issue_number)
  end

  def all_creators
    Creator.find_by_sql "SELECT DISTINCT creators.*
                        FROM creators
                        JOIN creator_credits
                        ON creator_credits.creator_id = creators.id
                        JOIN comics
                        ON creator_credits.comic_id = comics.id AND comics.weekly_list_id = #{self.id}
                        ORDER BY name"
  end

  def all_publishers
    Publisher.find_by_sql("SELECT DISTINCT publishers.*
                          FROM publishers
                          JOIN comics
                          ON comics.weekly_list_id = #{self.id} AND comics.publisher_id = publishers.id
                          ORDER BY name")
  end
end
