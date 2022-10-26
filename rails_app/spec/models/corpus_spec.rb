require 'rails_helper'

RSpec.describe Corpus, type: :model do
  let(:subject) { create :corpus }

  describe '#chants_unseen_by_last_import' do
    it 'does not find Chants belonging to the last (and only) import' do
      import = create :started_import, corpus: subject
      chant = create :chant, corpus: subject, import: import

      expect(subject.chants_unseen_by_last_import).not_to include chant
    end

    it 'does not find Chants belonging to the last (NOT only) import' do
      create :import, corpus: subject, started_at: 3.days.ago
      last_import = create :import, corpus: subject, started_at: 1.minute.ago

      chant = create :chant, corpus: subject, import: last_import

      expect(subject.chants_unseen_by_last_import).not_to include chant
    end

    it 'finds Chants belonging to an older import' do
      old_import = create :import, corpus: subject, started_at: 3.days.ago
      create :import, corpus: subject, started_at: 1.minute.ago

      chant = create :chant, corpus: subject, import: old_import

      expect(subject.chants_unseen_by_last_import).to include chant
    end

    it 'finds Chants belonging to no import' do
      create :started_import, corpus: subject

      chant = create :chant, corpus: subject, import: nil

      expect(subject.chants_unseen_by_last_import).to include chant
    end

    describe 'no imports available' do
      it 'always returns an empty Array' do
        chant = create :chant, corpus: subject, import: nil

        expect(subject.chants_unseen_by_last_import).to eq []
      end
    end
  end
end
