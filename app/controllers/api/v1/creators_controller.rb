class Api::V1::CreatorsController < ApplicationController
  def index
    query = log_query do
      ApiQueryBuilder.new.build_query_for_creators index_params
    end
    @creators = Creator.includes(:writer_credits,
                                 :artist_credits,
                                 :cover_artist_credits
                                ).where(query).order(:name)
    respond_to do |format|
      format.json { render :index }
    end

  rescue ActionController::UnknownFormat
    render json: { status: 400, message: 'Wrong format' }, status: 400
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
    @worked_for_publishers = @creator&.worked_for_publishers

    respond_to do |format|
      format.json { render :show }
    end

  rescue ArgumentError
    render json: { message: "Wrong query params: should have 'name' param" }, status: 400
  rescue ActionController::UnknownFormat
    render json: { message: 'Wrong format' }, status: 400
  end

  private

  def index_params
    params.permit(:names)
  end

  def show_params
    params.permit(:name)
  end
end
