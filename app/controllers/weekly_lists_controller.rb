class WeeklyListsController < ApplicationController
  def new_releases
    @weekly_list = WeeklyList.current_week_list
    @comics = @weekly_list.fetch_comics
    @creators = @weekly_list.all_creators
  end
end
