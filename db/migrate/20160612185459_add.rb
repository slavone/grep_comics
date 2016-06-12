class Add < ActiveRecord::Migration[5.0]
  def change
    add_index :comics, :diamond_code
    add_index :comics, :title
    add_index :comics, :shipping_date
    add_index :publishers, :name
  end
end
