describe MultipleSettingsFinder do
  before :each do
    @corpus = create :in_adiutorium_corpus
  end

  def create_chant(**args)
    create :chant, corpus: @corpus, **args
  end

  describe 'nothing to find' do
    it 'returns an empty Relation' do
      expect(subject.call).to be_empty
    end
  end

  describe 'Chants not having the same lyrics' do
    it 'does not find them' do
      create_chant lyrics_normalized: 'a'
      create_chant lyrics_normalized: 'b'

      expect(subject.call).to be_empty
    end
  end

  describe 'Chants having the same lyrics, but related' do
    it 'does not find them' do
      first_chant = create_chant lyrics_normalized: 'a'
      create_chant lyrics_normalized: 'a', parent: first_chant

      expect(subject.call).to be_empty
    end
  end

  describe 'unrelated Chants with the same lyrics' do
    describe 'exactly the same lyrics' do
      it 'finds them' do
        first_chant = create_chant lyrics_normalized: 'a'
        create_chant lyrics_normalized: 'a'

        result = subject.call
        expect(result.size).to eq 1

        # result of a grouped query
        expect(result[0].id).to be nil

        # ad hoc computed columns
        expect(result[0].lyrics_further_normalized).to eq first_chant.lyrics_normalized
        expect(result[0].group_size).to eq 2
      end
    end

    describe 'differ in a trailing aleluja' do
      it 'finds them' do
        first_chant = create_chant lyrics_normalized: 'a'
        create_chant lyrics_normalized: 'a aleluja'

        result = subject.call
        expect(result.size).to eq 1
        expect(result[0].lyrics_further_normalized).to eq first_chant.lyrics_normalized
      end
    end

    describe 'exactly the same textus_approbatus, different lyrics' do
      it 'finds them' do
        first_chant =
          create_chant lyrics_normalized: 'a', textus_approbatus_normalized: 'c'
        create_chant lyrics_normalized: 'b', textus_approbatus_normalized: 'c'

        result = subject.call
        expect(result.size).to eq 1
        expect(result[0].lyrics_further_normalized).to eq first_chant.textus_approbatus_normalized
      end
    end

    describe 'lyrics of one are the same as textus_approbatus of the other' do
      it 'finds them' do
        first_chant =
          create_chant lyrics_normalized: 'a'
        create_chant lyrics_normalized: 'b', textus_approbatus_normalized: 'a'

        result = subject.call
        expect(result.size).to eq 1
        expect(result[0].lyrics_further_normalized).to eq first_chant.lyrics_normalized
      end
    end
  end
end
