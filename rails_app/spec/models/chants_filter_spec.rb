RSpec.describe ChantsFilter do
  describe '#empty?' do
    it 'empty' do
      expect(described_class.new.empty?).to be true
    end

    it 'not empty' do
      expect(described_class.new('some value').empty?).to be false
    end
  end
end
