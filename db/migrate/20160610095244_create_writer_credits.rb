class CreateWriterCredits < ActiveRecord::Migration[5.0]
  def change
    create_table :writer_credits do |t|
      t.references :creator
      t.references :comic

      t.timestamps
    end
  end
end
