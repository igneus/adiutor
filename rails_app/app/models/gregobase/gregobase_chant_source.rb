module Gregobase
  class GregobaseChantSource < GregobaseRecord
    belongs_to :gregobase_source, foreign_key: 'source'
    belongs_to :gregobase_chant, foreign_key: 'chant_id'
  end
end
