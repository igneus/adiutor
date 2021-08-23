class Chant < ApplicationRecord
  def self.genres
    distinct.pluck(:quid).compact.sort
  end

  def self.modi_and_differentiae
    distinct
      .pluck(:modus, :differentia)
      .sort_by {|i| i[0].to_s }
      .group_by {|i| i[0] }
      .transform_values {|v| v.collect {|i| i[1] }.sort_by(&:to_s) }
  end

  def link_text
    lyrics.present? ? lyrics : fial
  end

  def fial
    "#{source_file_path}##{chant_id}"
  end
end
