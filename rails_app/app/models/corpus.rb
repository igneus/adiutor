# Corpus is a collection of Chants imported from a single (data) source
# by a single importer.
class Corpus < ApplicationRecord
  self.table_name = 'corpuses'

  has_many :music_books
  has_many :chants
  has_many :imports

  def import!
    importer.(sources_path)
  end

  def importer
    class_name = system_name.camelize + 'Importer'

    Kernel.const_get(class_name).new(self)
  end

  def sources_path
    varname = system_name.upcase + '_SOURCES_PATH'

    ENV[varname] ||
      raise("Expected environment variable #{varname} to contain path of the directory" \
        " with source code of the #{system_name} corpus, but the variable wath not found")
  end

  # Hash<mode => Hash<differentia => Array<String - unique melody incipits>>>
  def differentiae
    chants
      .all_antiphons
      .select(:modus, :differentia, 'SUBSTRING(volpiano, 1, 10) as melody_incipit', 'COUNT(modus) as occurrences')
      .where('volpiano IS NOT NULL')
      .group(:modus, :differentia, :melody_incipit)
      .group_by(&:modus)
      .transform_values {|v| v.group_by(&:differentia) }
  end

  def last_import
    imports.order(started_at: :desc).limit(1).first
  end

  def chants_unseen_by_last_import
    i = last_import
    return [] if i.nil?

    chants
      .where(import: nil)
      .or(chants.where.not(import: i))
  end
end
