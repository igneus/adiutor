module Gregobase
  class Chant < Record
    has_many :chant_sources
    has_and_belongs_to_many :tags, join_table: :gregobase_chant_tags
  end
end
