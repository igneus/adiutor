describe VolpianoDerivates do
  describe '.pitch_series' do
    it 'works' do
      expect(described_class.pitch_series('cijc'))
        .to eq 'c-ij-c'
    end
  end

  describe '.interval_series' do
    it 'works' do
      expect(described_class.interval_series('1---cd-dhij-h'))
        .to eq '+2+5+2-2'
    end

    it 'crashes without clef' do
      expect { described_class.interval_series('cd') }
        .to raise_exception(PyCall::PyError, /missing clef/i)
    end
  end

  describe '.snippet_to_interval_series' do
    it 'works without clef' do
      expect(described_class.snippet_to_interval_series('cd-dhij-h'))
        .to eq '+2+5+2-2'
    end
  end
end
