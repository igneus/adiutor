module ChantsHelper
  def chant_tags(chant)
    c = []
    c << 'quality notice' if chant.marked_for_revision?
    c << 'favourite' if chant.placet == '*'
    c << 'edited lyrics' if chant.lyrics_edited?

    c
  end

  def lyrics_diff(chant)
    Diffy::Diff
      .new(chant.textus_approbatus, chant.lyrics)
      .to_s(:html)
  end

  def lilypond_syntax_highlight(code)
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexers::TeX.new # rouge does not have a proper lexer for LilyPond

    formatter
      .format(lexer.lex(code))
      .each_line
      .with_index
      .collect {|l, i| link_to(l.rstrip.html_safe, open_in_editor_chant_path(line: i), method: :post) + "\n" }
      .join
  end
end
