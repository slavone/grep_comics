class CreatorsController < ApplicationController
  def index
    @creators = Creator.all.order(:name).preload(:writer_credits, :artist_credits, :cover_artist_credits)
  end

  def show
    @creator = Creator.preload(comics_as_writer: :publisher,
                               comics_as_artist: :publisher,
                               comics_as_cover_artist: :publisher
                              ).find params[:id]
    @publishers = @creator.worked_for_publishers
  end
end
