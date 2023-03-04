# Wrapper for lygre's GabcParser with simpler interface.
class MyGabcParser
  def self.call(source)
    parser = SimpleGabcParser.new
    parser.parse(source)&.create_score ||
      raise(parser_failure_msg(parser))
  end

  private

  def self.parser_failure_msg(parser)
    "'#{parser.failure_reason}' on line #{parser.failure_line} column #{parser.failure_column}"
  end
end
