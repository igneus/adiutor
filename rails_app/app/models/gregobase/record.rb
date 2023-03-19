module Gregobase
  class Record < ActiveRecord::Base
    self.abstract_class = true
    self.table_name_prefix = 'gregobase_'
    connects_to database: {reading: :gregobase, writing: :gregobase}
  end
end
