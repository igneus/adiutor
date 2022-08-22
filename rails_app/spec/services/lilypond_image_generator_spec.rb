describe LilypondImageGenerator do
  describe '.buildable_code' do
    it 'prepends minimal necessary settings' do
      input = '\score {}'
      expect(described_class.buildable_code(input)).to eq \
        <<~'EOS'
        \version "2.19.0"
        \include "adiutor_preview_settings.ly"
        \score {}
        EOS
    end

    it 'removes anything before \score beginning' do
      input = 'variable = \score {}'
      expect(described_class.buildable_code(input)).to eq \
        <<~'EOS'
        \version "2.19.0"
        \include "adiutor_preview_settings.ly"
        \score {}
      EOS
    end
  end
end
