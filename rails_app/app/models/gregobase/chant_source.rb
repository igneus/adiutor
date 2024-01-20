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

    # The table has a composite primary key, which is not supported by ActiveRecord
    # and results in #== not working the expected way.
    # An alternative solution would be to migrate the table after each load
    # of the GregoBase DB dump to a more Rails-friendly schema.
    def same?(other)
      keys == other.keys
    end

    def keys
      [chant_id, source_id, page]
    end
  end
end
