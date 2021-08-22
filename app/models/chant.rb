class Chant < ApplicationRecord
  def link_text
    lyrics.present? ? lyrics : fial
  end

  def fial
    "#{in_project_path}##{chant_id}"
  end

  private

  def in_project_path
    source_file_path.sub(ENV['IN_ADIUTORIUM_SOURCES_PATH'] + '/', '')
  end
end
