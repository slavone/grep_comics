class WeeklyListsController < ApplicationController
  def new_releases
    @weekly_list = WeeklyList.current_week_list
    @comics = @weekly_list&.fetch_comics
    @creators_filters = @weekly_list&.all_creators
    @publishers_filters = @weekly_list&.all_publishers
    render :show
  end

  def show
    @weekly_list = WeeklyList.find_by_closest_date params[:date]
    @comics = @weekly_list&.fetch_comics
    @creators_filters = @weekly_list&.all_creators
    @publishers_filters = @weekly_list&.all_publishers
  end
end
