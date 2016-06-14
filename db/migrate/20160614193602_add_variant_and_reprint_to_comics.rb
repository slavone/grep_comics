class AddVariantAndReprintToComics < ActiveRecord::Migration[5.0]
  def change
    add_column :comics, :is_variant, :bool
    add_column :comics, :reprint_number, :smallint
  end
end
