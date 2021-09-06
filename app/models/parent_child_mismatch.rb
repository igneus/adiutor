# Marks a score as potentially out of sync with its and worth a check.
class ParentChildMismatch < ApplicationRecord
  belongs_to :child, class_name: 'Chant'
  delegate :parent, to: :child

  scope :unresolved, -> { where(resolved_at: nil) }

  def self.next_to(mismatch)
    where('id > ?', mismatch.id).order(id: :asc).first
  end

  def relation
    FIAL.parse(child.fial).additional
  end

  def simple_copy?
    relation == {}
  end
end
