class Api::V1::PublishersController < ApplicationController
  def index
    query = log_query do
      ApiQueryBuilder.new.build_query_for_publishers params
    end
    @publishers = Publisher.includes(:comics).where(query).order(:name)
    render :index
  end
end
