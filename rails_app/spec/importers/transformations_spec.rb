RSpec.describe Transformations do
  describe '.empty_str_to_nil' do
    it { expect(subject.empty_str_to_nil('')).to eq nil }
    it { expect(subject.empty_str_to_nil('a')).to eq 'a' }
    it { expect(subject.empty_str_to_nil(6)).to eq 6 }
  end
end
