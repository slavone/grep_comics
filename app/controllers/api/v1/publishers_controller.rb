class Api::V1::PublishersController < ApplicationController
  def index
    query = log_query do
      ApiQueryBuilder.new.build_query_for_publishers index_params
    end
    @publishers = Publisher.includes(:comics).where(query).order(:name)
    respond_to do |format|
      format.json { render :index }
    end
  rescue ActionController::UnknownFormat
    render json: { status: 400, message: 'Wrong format' }, status: 400
  end

  private

  def index_params
    params.permit(:names)
  end
end
