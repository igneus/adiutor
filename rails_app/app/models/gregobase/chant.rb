module Gregobase
  class Chant < Record
    has_many :chant_sources
    has_and_belongs_to_many :tags, join_table: :gregobase_chant_tags

    # chants not linked to any book
    scope :without_source, -> { left_joins(:chant_sources).where(chant_sources: {chant_id: nil}) }
  end
end
