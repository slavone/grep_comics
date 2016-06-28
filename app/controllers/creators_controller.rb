class CreatorsController < ApplicationController
  def index
    @creators = Creator.all.order(:name).preload(:writer_credits, :artist_credits, :cover_artist_credits)
  end

  def show
    @creator = Creator.find params[:id]
    @comics_as_writer = @creator.comics_as_writer
    @comics_as_artist = @creator.comics_as_artist
    @comics_as_cover_artist = @creator.comics_as_cover_artist
    @publishers = @creator.worked_for_publishers
  end
end
