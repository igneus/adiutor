# coding: utf-8
# Edits In adiutorium corpus sources, adding a quality notice
# to the specified chant.
class AddQualityNotice
  Result = Struct.new(:message) do
    def error?
      !message.nil?
    end
  end

  def call(chant)
    if chant.corpus != Corpus.find_by_system_name!('in_adiutorium')
      raise 'unsupported corpus'
    end

    output, status = Dir.chdir(Adiutor::IN_ADIUTORIUM_SOURCES_PATH) do
      Open3.capture2e("ruby nastroje/addheader.rb #{chant.fial_of_self} placet lépe")
    end

    Result.new(status.exitstatus == 0 ? nil : output)
  end
end
