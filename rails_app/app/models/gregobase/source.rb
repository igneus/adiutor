module Gregobase
  class Source < Record
    has_many :chant_sources, inverse_of: :source, foreign_key: 'source'

    def contained_office_parts
      chant_sources
        .joins(:chant)
        .select('gregobase_chants.`office-part` AS office_part')
        .distinct
        .collect(&:office_part)
    end
  end
end
