class WeeklyListsController < ApplicationController
  def new_releases
    @weekly_list = WeeklyList.current_week_list
    @comics = @weekly_list.fetch_comics
    @creators = @weekly_list.all_creators
    render :show
  end

  def show
    @weekly_list = WeeklyList.find_by_closest_date params[:date]
    @comics = @weekly_list.fetch_comics
    @creators = @weekly_list.all_creators
  end
end
