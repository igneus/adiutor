module Transformations
  extend self

  def empty_str_to_nil(v)
    v == '' ? nil : v
  end
end
