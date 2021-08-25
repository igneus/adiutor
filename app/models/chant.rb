class Chant < ApplicationRecord
  belongs_to :book
  belongs_to :cycle
  belongs_to :parent, class_name: 'Chant', optional: true
  has_many :children, class_name: 'Chant', foreign_key: 'parent_id'

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

  def parental_tree_top
    parent.nil? ? self : parent.parental_tree_top
  end

  def link_text
    lyrics.present? ? lyrics : fial_of_self
  end

  def fial_of_self
    "#{source_file_path}##{chant_id}"
  end

  def marked_for_revision?
    placet.present? && placet != '*'
  end

  def lyrics_edited?
    textus_approbatus.present?
  end
end
