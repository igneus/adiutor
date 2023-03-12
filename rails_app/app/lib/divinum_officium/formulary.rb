# Understands format of the divinumofficium.com data files,
# allows enumerating the contents.
module DivinumOfficium
  class Formulary
    Item = Struct.new(:title, :text) do
      def is_reference?
        text.start_with? '@'
      end
    end

    def initialize(source)
      @items = parse source
    end

    attr_reader :items

    def antiphons
      items.select {|i| i.title.include? 'Ant' }
    end

    private

    def parse(source)
      r = []
      source.scan(/^\[(.+?)\]$([^\[]*)/) do |title, text|
        r << Item.new(title, text.strip.sub(/;;[\d;]*$/, ''))
      end

      r
    end
  end
end
