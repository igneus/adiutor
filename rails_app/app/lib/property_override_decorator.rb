require 'delegate'

# Decorates an object, adding or overriding specified methods
# to return specified values
class PropertyOverrideDecorator < SimpleDelegator
  def initialize(obj, **properties)
    super(obj)

    properties.each_pair do |key, val|
      self.define_singleton_method(key) { val }
    end
  end
end
