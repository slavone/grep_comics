class CreateApiKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :api_keys do |t|
      t.string :key
      t.integer :call_count, default: 0

      t.timestamps
    end
  end
end
