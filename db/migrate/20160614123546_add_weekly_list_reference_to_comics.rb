class AddWeeklyListReferenceToComics < ActiveRecord::Migration[5.0]
  def change
    add_reference :comics, :weekly_list, foreign_key: true
  end
end
