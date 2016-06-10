class CreateComics < ActiveRecord::Migration[5.0]
  def change
    create_table :comics do |t|
      t.string :diamond_code
      t.string :title
      t.integer :issue_number
      t.text :preview
      t.decimal :suggested_price
      t.string :item_type
      t.date :shipping_date
      t.references :publisher, foreign_key: true, index: true

      t.timestamps
    end
  end
end
