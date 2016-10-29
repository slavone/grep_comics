# == Schema Information
#
# Table name: comics
#
#  id                 :integer          not null, primary key
#  diamond_code       :string
#  title              :string
#  issue_number       :integer
#  preview            :text
#  suggested_price    :decimal(, )
#  item_type          :string
#  shipping_date      :date
#  publisher_id       :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  cover_image        :string
#  weekly_list_id     :integer
#  is_variant         :boolean
#  reprint_number     :integer
#  cover_thumbnail    :string
#  no_cover_available :boolean
#
# Foreign Keys
#
#  fk_rails_4c749ccbd2  (publisher_id => publishers.id)
#  fk_rails_812b74135e  (weekly_list_id => weekly_lists.id)
#

class Comic < ApplicationRecord
  belongs_to :publisher, optional: true
  belongs_to :weekly_list, optional: true

  include CreatorCredits
  has_many :writers, -> { order(:name) }, through: :writer_credits, source: :creator
  has_many :artists, -> { order(:name) }, through: :artist_credits, source: :creator
  has_many :cover_artists, -> { order(:name) }, through: :cover_artist_credits, source: :creator

  mount_uploader :cover_thumbnail, CoverUploader

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
        "#{creators}"
      else
        creators.map { |c| "#{c}"}.join('|')
      end
    end

    def item_types
      ITEM_TYPES_MAPPING.map { |_, v| v }
    end
  end

  scope :filtered_by_creators, ->(creators) do
    creators_query = Comic.build_creators_query creators
    find_by_sql  "SELECT DISTINCT comics.*
                 FROM comics
                 JOIN creator_credits ON comics.id = creator_credits.comic_id
                 JOIN creators ON creators.id = creator_credits.creator_id
                 WHERE name ~* '(#{creators_query})'
                 ORDER BY title"
  end

  scope :filtered_by_creators_of_type, ->(creators, type) do
    creators_query = Comic.build_creators_query creators
    find_by_sql  "SELECT DISTINCT comics.*
                 FROM comics
                 JOIN creator_credits
                 ON comics.id = creator_credits.comic_id AND creator_credits.credited_as = '#{type}'
                 JOIN creators
                 ON creators.id = creator_credits.creator_id
                 WHERE name ~* '(#{creators_query})'
                 ORDER BY title"
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
