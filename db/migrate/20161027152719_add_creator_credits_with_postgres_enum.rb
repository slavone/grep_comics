class AddCreatorCreditsWithPostgresEnum < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE TYPE creator_type AS ENUM ('writer', 'artist', 'cover_artist');
    SQL

    create_table :creator_credits do |t|
      t.references :creator
      t.references :comic
      t.timestamps
    end

    add_column :creator_credits, :credited_as, :creator_type
  end

  def down
    drop_table :creator_credits

    execute <<-SQL
      DROP TYPE creator_type;
    SQL
  end
end
