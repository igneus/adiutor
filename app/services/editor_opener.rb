# Knows how to open a Chant in an editor
# (only makes sense when running on a local workstation)
class EditorOpener
  def call(chant)
    project_root = ENV['IN_ADIUTORIUM_SOURCES_PATH']
    tool = File.join project_root, 'nastroje', 'editfial.rb'

    Dir.chdir(project_root) do
      `ruby #{tool} #{chant.fial}`
    end
  end
end
