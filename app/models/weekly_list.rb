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
  class << self
    def current_week_list
      WeeklyList.order(wednesday_date: :desc).first
    end
  end

  def fetch_comics
    Comic.where(shipping_date: self.wednesday_date).includes(:publisher, :writers, :artists, :cover_artists).order('publishers.name', :title)
  end

end
