class Api::V1::ComicsController < ApplicationController
  def index
    query = log_query do
      ApiQueryBuilder.new.build_query_for_comics comics_params
    end
    @comics = Comic.eager_load(:publisher)
                   .preload(:writers, :artists, :cover_artists)
                   .where(query)
                   .order('publishers.name', :title, :issue_number)

    respond_to do |format|
      format.json { render :index }
    end

  rescue ActionController::UnknownFormat
    render json: { message: 'Wrong format' }, status: 400
  end

  def weekly_releases
    raise ArgumentError unless params[:date]

    query = log_query do
      builder = ApiQueryBuilder.new
      query = builder.build_query_for_comics comics_params
    end
    weekly_list = WeeklyList.find_by_closest_date params[:date]
    @comics = weekly_list&.fetch_comics&.where query

    respond_to do |format|
      format.json { render :index }
    end

  rescue ArgumentError
    render json: { message: "Wrong query params: should have 'date' param." }, status: 400
  rescue ActionController::UnknownFormat
    render json: { message: 'Wrong format' }, status: 400
  end

  private

  def comics_params
    params.permit :publisher, :title, :creators, :writers,
                  :artists, :cover_artists, :shipping_date,
                  :has_variant_covers, :issue_number, :reprint,
                  :type

  end
end
