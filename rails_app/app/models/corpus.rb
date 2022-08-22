# Represents a corpus of chants.
class Corpus < ApplicationRecord
  self.table_name = 'corpuses'

  has_many :chants

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
end
