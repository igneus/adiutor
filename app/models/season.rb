class Season < ApplicationRecord
  def self.for_cr_season(cr_season)
    find_by_system_name! cr_season.symbol
  end
end
