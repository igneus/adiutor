module Gregobase
  class GregobaseSource < GregobaseRecord
    has_many :gregobase_chant_sources, inverse_of: :gregobase_source, foreign_key: 'source'
  end
end
