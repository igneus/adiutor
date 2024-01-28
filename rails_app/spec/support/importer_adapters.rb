# shared examples for testing the import adapters

# for testing that the subset of Adapter attributes provided on initialization
# is delegated correctly
shared_examples 'attributes passed from the outside' do |attributes|
  let(:other_constructor_args) { [nil] * (described_class.instance_method(:initialize).arity - 1) }

  attributes.each do |a|
    it a do
      value = 'value'
      attrs = OpenStruct.new a => value
      adapter = described_class.new(attrs, *other_constructor_args)

      expect(adapter.public_send(a)).to be value
    end
  end
end
