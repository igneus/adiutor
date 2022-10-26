require 'rails_helper'

RSpec.describe Import, type: :model do
  let(:subject) { described_class.new(corpus: create(:corpus)) }

  describe '#do!' do
    it 'yields' do
      expect {|probe| subject.do!(&probe) }
        .to yield_control
    end

    it 'yields itself' do
      subject.do! do |x|
        expect(x).to be subject
      end
    end

    it 'sets started_at and persists before yielding' do
      subject.do! do |x|
        expect(x.started_at).not_to be_nil
        expect(Time.now - x.started_at). to be < 1

        expect(x).to be_persisted
        expect(x).not_to be_changed
      end
    end

    it 'sets finished_at and persists after the block finishes' do
      subject.do! {}

      x = subject
      expect(x.finished_at).not_to be_nil
      expect(Time.now - x.finished_at). to be < 1

      expect(x).to be_persisted
      expect(x).not_to be_changed
    end

    describe 'exception handling' do
      it 'does not swallow the exception' do
        e = RuntimeError.new 'my exception'

        expect do
          subject.do! { raise e }
        end.to raise_exception e
      end

      it 'sets finished_at and persists' do
        begin
          subject.do! { raise 'exception' }
        rescue
        end

        expect(subject.finished_at).not_to be_nil
        expect(subject).not_to be_changed
      end
    end
  end

  describe '#start!' do
    it 'cannot be started repeatedly' do
      subject.start!

      expect { subject.start! }
        .to raise_exception /already started/i
    end
  end
end
