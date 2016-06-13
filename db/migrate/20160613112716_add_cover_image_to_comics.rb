class AddCoverImageToComics < ActiveRecord::Migration[5.0]
  def change
    add_column :comics, :cover_image, :string
  end
end
