class AddCoverThumbnailToComics < ActiveRecord::Migration[5.0]
  def change
    add_column :comics, :cover_thumbnail, :string
  end
end
