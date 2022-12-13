module Gregobase
  class GregobaseSource < GregobaseRecord
    has_many :gregobase_chant_sources, inverse_of: :gregobase_source, foreign_key: 'source'

    def contained_office_parts
      gregobase_chant_sources
        .joins(:gregobase_chant)
        .select('gregobase_chants.`office-part` AS office_part')
        .distinct
        .collect(&:office_part)
    end
  end
end
