module Gregobase
  class GregobaseRecord < ActiveRecord::Base
    self.abstract_class = true
    connects_to database: {reading: :gregobase, writing: :gregobase}
  end
end
