describe PropertyOverrideDecorator do
  let(:not_decorated) do
    Struct.new(:method_a, :method_b).new('a', 'b')
  end

  describe 'not decorated' do
    let(:subject) { not_decorated }

    it { expect(subject.method_a).to eq 'a' }
  end

  describe 'partially overridden' do
    let(:subject) { described_class.new not_decorated, method_a: 111 }

    it { expect(subject.method_a).to eq 111 }
    it { expect(subject.method_b).to eq 'b' }
  end

  describe 'fully overridden' do
    let(:subject) { described_class.new not_decorated, method_a: 111, method_b: 222 }

    it { expect(subject.method_a).to eq 111 }
    it { expect(subject.method_b).to eq 222 }
  end
end
