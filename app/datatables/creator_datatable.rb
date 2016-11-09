class CreatorDatatable < AjaxDatatablesRails::Base

  include AjaxDatatablesRails::Extensions::Kaminari

  def_delegators :@view, :link_to, :creator_path

  def sortable_columns
    @sortable_columns ||= %w(Creator.name writer_credits_count artist_credits_count cover_artist_credits_count)
  end

  def searchable_columns
    @searchable_columns ||= %w(Creator.name)
  end

  def as_json(options = {})
    {
      :draw => params[:draw].to_i,
      :recordsTotal =>  Creator.count,
      :recordsFiltered => filter_records(Creator.all).size,
      :data => data
    }
  end

  private

  def data
    records.map do |record|
      [
        link_to(record.name, creator_path(record.id)),
        record.writer_credits_count,
        record.artist_credits_count,
        record.cover_artist_credits_count
      ]
    end
  end

  def get_raw_records
    Creator.joins("LEFT OUTER JOIN creator_credits cc ON cc.creator_id = creators.id")
           .select("creators.*")
           .select("COUNT(*) FILTER (WHERE cc.credited_as = 'writer') AS writer_credits_count")
           .select("COUNT(*) FILTER (WHERE cc.credited_as = 'artist') AS artist_credits_count")
           .select("COUNT(*) FILTER (WHERE cc.credited_as = 'cover_artist') AS cover_artist_credits_count")
           .group(:id)
  end
end
