class Chant < ApplicationRecord
  def link_text
    lyrics.present? ? lyrics : fial
  end

  def fial
    "#{source_file_path}##{chant_id}"
  end
end
