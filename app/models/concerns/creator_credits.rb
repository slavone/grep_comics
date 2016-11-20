module CreatorCredits
  def self.included(klass)
    klass_name = klass.name.downcase.to_sym

    klass.has_many :creator_credits, dependent: :destroy
    klass.has_many :writer_credits, -> { where(credited_as: :writer) }, class_name: 'CreatorCredit', inverse_of: klass_name
    klass.has_many :artist_credits, -> { where(credited_as: :artist) }, class_name: 'CreatorCredit', inverse_of: klass_name
    klass.has_many :cover_artist_credits, -> { where(credited_as: :cover_artist) }, class_name: 'CreatorCredit', inverse_of: klass_name
  end
end
