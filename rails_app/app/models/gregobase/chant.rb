module Gregobase
  class Chant < Record
    has_one :chant_source
    has_and_belongs_to_many :tags, join_table: :gregobase_chant_tags
  end
end
