class Api::V1::PublishersController < ApplicationController
  def index
    query = log_query do
      ApiQueryBuilder.new.build_query_for_publishers params
    end
    @publishers = Publisher.includes(:comics).where(query).order(:name)
    respond_to do |format|
      format.json { render :index }
    end
  rescue ActionController::UnknownFormat
    render json: { status: 400, message: 'Wrong format' }, status: 400
  end
end
