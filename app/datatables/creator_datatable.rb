class CreatorDatatable < AjaxDatatablesRails::Base

  include AjaxDatatablesRails::Extensions::Kaminari

  def_delegators :@view, :link_to, :creator_path

  def sortable_columns
    @sortable_columns ||= %w(Creator.name)
  end

  def searchable_columns
    @searchable_columns ||= %w(Creator.name)
  end

  private

  def data
    records.map do |record|
      [
        link_to(record.name, creator_path(record.id)),
        record.writer_credits.size,
        record.artist_credits.size,
        record.cover_artist_credits.size
      ]
    end
  end

  def get_raw_records
    Creator.all.preload(:writer_credits, :artist_credits, :cover_artist_credits)
  end
end
