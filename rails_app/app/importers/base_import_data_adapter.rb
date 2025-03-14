# ImportDataAdapter encapsulates contents of a single chant from the source
# data, exposes them transformed to a format which can be directly
# copied to corresponding properties of a Chant instance.
#
# Names of public methods match names of Chant attributes
# to allow convenient copying.
class BaseImportDataAdapter
  extend Forwardable

  # Chant attributes which should be copied from the adapter.
  def self.attributes
    public_instance_methods - Object.public_instance_methods
  end

  # Chant attributes not implemented by the adapter
  # (default - empty - implementation inherited from this base class).
  def self.unimplemented_attributes
    attributes.reject {|a| method_defined?(a, false) }
  end

  # defines methods finding Chant associations by system name
  def self.find_associations_by_system_name(*associations)
    associations.each do |a|
      define_method a do
        model = Object.const_get(a.capitalize)
        system_name = public_send "#{a}_system_name"
        system_name && model.find_by_system_name!(system_name)
      end
    end
  end

  # associations

  def book
  end

  def cycle
  end

  def season
  end

  def hour
  end

  def genre
  end

  # data fields

  def source_code
  end

  def lyrics
  end

  def textus_approbatus
  end

  def lyrics_normalized
  end

  def header
  end

  def modus
  end

  def differentia
  end

  def alleluia_optional
  end

  # metadata fields specific to the In adiutorium corpus

  def quid
  end

  def psalmus
  end

  def placet
  end

  def fial
  end

  def simple_copy
    false
  end

  def copy
    false
  end

  # stats

  def syllable_count
  end

  def word_count
    lyrics.split(/\s+/).size
  end

  def melody_section_count
  end
end
