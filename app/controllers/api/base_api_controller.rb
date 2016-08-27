class Api::BaseApiController < ApplicationController
  before_action :authenticate_key!

  private

  def authorization_params
    params.permit(:key)
  end

  def authenticate_key!
    unless authorization_params[:key]
      render json: { status: 401, message: 'Unauthorized. No key provided' }, status: 401
      return
    end
    
    key = ApiKey.find_by(key: params[:key])
    if key
      key.increment! :call_count
    else
      render json: { status: 401, message: 'Unauthorized. Wrong key' }, status: 401
      return
    end
  end

  def log_query
    logger.info '------------------------'
    logger.info "Got params #{params.inspect}"
    query = yield
    logger.info "Build query #{query}"
    query
  end

  def logger
    @logger = Logger.new "#{Rails.root}/log/api_v1.log"
  end
end
