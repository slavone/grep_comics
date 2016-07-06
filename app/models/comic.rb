# == Schema Information
#
# Table name: comics
#
#  id              :integer          not null, primary key
#  diamond_code    :string
#  title           :string
#  issue_number    :integer
#  preview         :text
#  suggested_price :decimal(, )
#  item_type       :string
#  shipping_date   :date
#  publisher_id    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cover_image     :string
#  weekly_list_id  :integer
#  is_variant      :boolean
#  reprint_number  :integer
#
# Foreign Keys
#
#  fk_rails_4c749ccbd2  (publisher_id => publishers.id)
#  fk_rails_812b74135e  (weekly_list_id => weekly_lists.id)
#

class Comic < ApplicationRecord
  belongs_to :publisher
  belongs_to :weekly_list, optional: true
  has_many :writer_credits
  has_many :writers, -> { order(:name) }, through: :writer_credits, source: :creator
  has_many :artist_credits
  has_many :artists, -> { order(:name) }, through: :artist_credits, source: :creator
  has_many :cover_artist_credits
  has_many :cover_artists, -> { order(:name) }, through: :cover_artist_credits, source: :creator

  ITEM_TYPES_MAPPING = {
    'single_issue' => 'SINGLE ISSUE',
    'hardcover' => 'HARDCOVER',
    'softcover' => 'SOFTCOVER',
    'trade_paperback' => 'TRADE PAPERBACK',
    'graphic_novel' => 'GRAPHIC NOVEL'
  }.freeze

  class << self
    def build_creators_query(creators)
      if creators.kind_of? String
        "'#{creators}'"
      else
        creators.map { |c| "'#{c}'"}.join(',')
      end
    end

    def item_types
      ITEM_TYPES_MAPPING.map { |_, v| v }
    end
  end

  scope :filtered_by_creators, ->(creators) do
    creators_query = Comic.build_creators_query creators
    find_by_sql "WITH filtered_creators AS (
                SELECT id
                FROM creators
                WHERE
                name IN (#{creators_query})
                )
                SELECT DISTINCT comics.*
                FROM comics
                WHERE
                id IN (
                  SELECT writer_credits.comic_id
                  FROM writer_credits JOIN filtered_creators
                  ON writer_credits.creator_id = filtered_creators.id
                  UNION ALL
                  SELECT artist_credits.comic_id
                  FROM artist_credits JOIN filtered_creators
                  ON artist_credits.creator_id = filtered_creators.id
                  UNION ALL
                  SELECT cover_artist_credits.comic_id
                  FROM cover_artist_credits JOIN filtered_creators
                  ON cover_artist_credits.creator_id = filtered_creators.id
                )"
  end

  scope :filtered_by_creators_of_type, ->(creators, type) do
    creators_query = Comic.build_creators_query creators
    find_by_sql "WITH filtered_creators AS (
                SELECT id
                FROM creators
                WHERE
                name IN (#{creators_query})
                )
                SELECT DISTINCT comics.*
                FROM comics
                WHERE
                id IN (
                  SELECT #{type}_credits.comic_id
                  FROM #{type}_credits JOIN filtered_creators
                  ON #{type}_credits.creator_id = filtered_creators.id
                )"
  end

  def humanized_title
    (title +
     "#{' #' + issue_number.to_s if item_type == 'single_issue'}" +
     "#{' VARIANT' if is_variant}" +
     "#{" #{reprint_number} PRINTING" if reprint_number && reprint_number > 1}").strip
  end


  def humanized_item_type
    ITEM_TYPES_MAPPING[item_type]
  end

end
