# Knows how to open a Chant in an editor
# (only makes sense when running on a local workstation)
class EditorOpener
  def call(chant, line = nil)
    project_root = Adiutor::IN_ADIUTORIUM_SOURCES_PATH
    tool = File.join project_root, 'nastroje', 'editfial.rb'

    fial = chant.fial_of_self
    fial += ":#{line}" if line

    Dir.chdir(project_root) do
      `ruby #{tool} #{fial}`
    end
  end
end
