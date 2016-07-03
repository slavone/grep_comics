class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

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
