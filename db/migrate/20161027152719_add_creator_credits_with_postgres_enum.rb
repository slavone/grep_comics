class AddCreatorCreditsWithPostgresEnum < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE TYPE creator_type AS ENUM ('writer', 'artist', 'cover_artist');
    SQL

    create_table :creator_credits do |t|
      t.references :creator
      t.references :comic, foreign_key: true
      t.timestamps
    end

    add_column :creator_credits, :credited_as, :creator_type
    add_index :creator_credits, [:creator_id, :credited_as]

    execute <<-SQL
      INSERT INTO creator_credits (creator_id, comic_id, created_at, updated_at, credited_as)
      SELECT creator_id, comic_id, created_at, current_timestamp AS updated_at, 'writer'::creator_type AS credited_as
      FROM writer_credits
      UNION
      SELECT creator_id, comic_id, created_at, current_timestamp AS updated_at, 'artist'::creator_type AS credited_as
      FROM artist_credits
      UNION
      SELECT creator_id, comic_id, created_at, current_timestamp AS updated_at, 'cover_artist'::creator_type AS credited_as
      FROM cover_artist_credits
      ORDER BY comic_id
    SQL

    drop_table :writer_credits
    drop_table :artist_credits
    drop_table :cover_artist_credits
  end

  def down
    %w(writer_credits artist_credits cover_artist_credits).each do |table|
      create_table table.to_sym do |t|
        t.references :creator, foreign_key: true
        t.references :comic, foreign_key: true
        t.timestamps
      end

      execute <<-SQL
        INSERT INTO #{table} (creator_id, comic_id, created_at, updated_at)
        SELECT creator_id, comic_id, created_at, current_timestamp AS updated_at
        FROM creator_credits
        WHERE credited_as = '#{table.gsub /_credits/, ''}'
        ORDER BY comic_id
      SQL
    end

    drop_table :creator_credits

    execute <<-SQL
      DROP TYPE creator_type;
    SQL
  end
end
