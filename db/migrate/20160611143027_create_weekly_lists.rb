class CreateWeeklyLists < ActiveRecord::Migration[5.0]
  def change
    create_table :weekly_lists do |t|
      t.text :list
      t.date :wednesday_date, index: true

      t.timestamps
    end
  end
end
