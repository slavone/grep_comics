class AddNoCoverAvailableFlagToComics < ActiveRecord::Migration[5.0]
  def change
    add_column :comics, :no_cover_available, :boolean
  end
end
