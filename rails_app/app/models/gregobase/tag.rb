module Gregobase
  class Tag < Record
    has_and_belongs_to_many :chants
  end
end
