class ComicsController < ApplicationController
  def show
    @comic = Comic.includes(:publisher)
                  .preload(:writers, :artists, :cover_artists)
                  .find params[:id]
  end
end
