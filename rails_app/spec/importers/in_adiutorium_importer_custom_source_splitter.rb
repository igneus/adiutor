describe InAdiutoriumImporter::CustomSourceSplitter do
  let(:source) do
    <<~'EOS'
    ignored preamble

    %%% spolecne
    shared content

    %%% i
    \score {
      \header { id = "i" }
    }

    %%% ii
    \score {
      \header {
        quid = "nada"
        id = "ii"
      }
    }
    EOS
  end
  let(:subject) { described_class.new source }

  it { expect(subject.source_by_id('unknown')).to be nil }
  it do
    expect(subject.source_by_id('ii')).to eq <<~'EOS'
    %%% spolecne
    shared content

    %%% ii
    \score {
      \header {
        quid = "nada"
        id = "ii"
      }
    }
    EOS
  end
end
