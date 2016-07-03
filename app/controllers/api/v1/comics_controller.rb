class Api::V1::ComicsController < ApplicationController
  def index
    query = log_query do
      ApiQueryBuilder.new.build_query_for_comics params
    end
    @comics = Comic.eager_load(:publisher)
                   .preload(:writers, :artists, :cover_artists)
                   .where(query)
                   .order('publishers.name', :title, :issue_number)
    render :index
  end

  def weekly_releases
    query = log_query do
      builder = ApiQueryBuilder.new
      query = builder.build_query_for_comics params
    end
    weekly_list = WeeklyList.find_by_closest_date params[:date]
    @comics = weekly_list.fetch_comics.where query
    render :index
  end
end
