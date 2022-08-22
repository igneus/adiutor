# Language in which a chant's (primary) source code is encoded.
class SourceLanguage < ApplicationRecord
  has_many :chants

  def image_generator
    Kernel.const_get("#{system_name.capitalize}ImageGenerator").new
  end
end
