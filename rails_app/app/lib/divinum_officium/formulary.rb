# Understands format of the divinumofficium.com data files,
# allows enumerating the contents.
module DivinumOfficium
  class Formulary
    Item = Struct.new(:title, :text, :section_pos) do
      def is_reference?
        text.start_with? '@'
      end
    end

    def initialize(source)
      @items = parse source
    end

    attr_reader :items

    def antiphons
      items.select do |i|
        i.title.include?('Ant') &&
          !i.text.start_with?('V. ')
      end
    end

    private

    def parse(source)
      r = []
      source.scan(/^\[(.+?)\]$([^\[]*)/) do |title, text|
        next if text.strip.empty?

        if title.include?('Ant') && text =~ /^V\..+?^R\./m
          # antiphon immediately followed by a versicle
          a, _, v = text.partition(/(?=^V\.)/)
          r << Item.new(title, scrub_text(a), 1)
          r << Item.new(title, scrub_text(v), 2)
        elsif title.include?('Ant') && text.strip.scan("\n").size > 0
          # series of antiphons
          text.strip.split(/(?<!~)$/).each.with_index(1) do |a, i|
            scrub_text(a).yield_self do |scrubbed|
              next if scrubbed.empty?
              r << Item.new(title, scrubbed, i)
            end
          end
        else
          scrub_text(text).yield_self do |scrubbed|
            next if scrubbed.empty?
            r << Item.new(title, scrubbed)
          end
        end
      end

      r
    end

    def scrub_text(str)
      str.strip.sub(/;;[\d;]*/, '').sub("~\n", ' ')
    end
  end
end
