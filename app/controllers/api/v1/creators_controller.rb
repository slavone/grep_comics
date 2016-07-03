class Api::V1::CreatorsController < ApplicationController
  def index
    query = log_query do
      ApiQueryBuilder.new.build_query_for_creators params
    end
    @creators = Creator.includes(:writer_credits,
                                 :artist_credits,
                                 :cover_artist_credits
                                ).where(query).order(:name)
    render :index
  end

  def show
    raise ArgumentError unless show_params[:name]
    query = log_query do
      ApiQueryBuilder.new.build_query_for_creators show_params
    end
    @creator = Creator.preload(comics_as_writer: :publisher,
                               comics_as_artist: :publisher,
                               comics_as_cover_artist: :publisher
                              ).where(query).first
    @worked_for_publishers = @creator.worked_for_publishers
    render :show
  rescue ArgumentError
    logger.info 'Wrong query params'
    render json: { status: 400, message: 'Wrong query params' }
  end

  private
  
  def show_params
    params.permit(:name)
  end
end
