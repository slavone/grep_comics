class Api::V1::ComicsController < ApplicationController
  def index
    @logger = Logger.new "#{Rails.root}/log/api_v1.log"
    @logger.info '------------------------'
    @logger.info "Got params #{params.inspect}"
    #query = build_query params
    query = ApiQueryBuilder.new.build_query_for_comics params
    @logger.info "Build query #{query}"
    @comics = Comic.eager_load(:publisher).preload(:writers, :artists, :cover_artists).where(query)
    render :index
  end
end
