class Api::V1::ComicsController < ApplicationController
  def index
    logger.info '------------------------'
    logger.info "Got params #{params.inspect}"
    query = ApiQueryBuilder.new.build_query_for_comics params
    logger.info "Build query #{query}"
    @comics = Comic.eager_load(:publisher)
                   .preload(:writers, :artists, :cover_artists)
                   .where(query)
                   .order('publishers.name', :title, :issue_number)
    render :index
  end

  def weekly_releases
    logger.info '------------------------'
    logger.info "Got params #{params.inspect}"
    builder = ApiQueryBuilder.new
    query = builder.build_query_for_comics params
    logger.info "Build query #{query}"
    weekly_list = WeeklyList.find_by_closest_date params[:date]
    @comics = weekly_list.fetch_comics.where query
    render :index
  end

  private 

  def logger
    @logger = Logger.new "#{Rails.root}/log/api_v1.log"
  end
end
