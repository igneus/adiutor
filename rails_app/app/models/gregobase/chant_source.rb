module Gregobase
  class ChantSource < Record
    belongs_to :source, foreign_key: 'source'
    belongs_to :chant, foreign_key: 'chant_id'

    # Expose value of the source foreign key
    # (not accessible the usual way due to column name
    # being the same as association name)
    def source_id
      read_attribute :source
    end
  end
end
