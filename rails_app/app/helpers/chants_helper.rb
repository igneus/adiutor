module ChantsHelper
  def chant_tags(chant)
    c = []
    c << 'quality notice' if chant.marked_for_revision?
    c << 'favourite' if chant.placet == '*'
    c << 'edited lyrics' if chant.lyrics_edited?
    if chant.simple_copy?
      c << 'copy simple'
    elsif chant.fial.present?
      c << 'copy'
    end
    c << 'mismatch' if chant.mismatches.present?
    c << 'hour missing' if chant.hour_id.nil?
    c << 'genre missing' if chant.genre_id.nil?
    c << corpus_shortcut(chant.corpus.name)

    c << 'OP' if chant.book.system_name == 'bsop'
    c << 'OSB' if %w(bm lhm).include? chant.book.system_name

    c
  end

  def corpus_shortcut(name)
    name
      .split(/[^\w]+/)
      .collect {|i| i =~ /^\d+$/ ? i : i[0] }
      .join
      .upcase
  end

  def edit_chant_button(chant, label=nil, variationes: false, render_if_unavailable: true, opts: {})
    label ||= 'Open in editor' + (variationes ? ' (variationes)' : '')
    opts = {method: :post, class: 'button'}.update opts
    if chant.corpus.system_name != 'in_adiutorium'
      opts.update(disabled: true, title: 'only available for the In adiutorium corpus')

      return '' unless render_if_unavailable
    end

    button_to(
      label,
      open_in_editor_chant_path(chant, variationes: variationes),
      opts
    )
  end

  def chant_gregobase_link(chant)
    chant
      .gregobase_chant_id
      &.yield_self do |gid|
      link_to "GregoBase #{gid}", "https://gregobase.selapa.net/chant.php?id=#{gid}"
    end
  end

  def diff(a, b)
    Diffy::Diff
      .new(a, b)
      .to_s(:html)
  end

  def lyrics_diff(chant)
    diff chant.textus_approbatus, chant.lyrics
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

  def tree_item_classes(chant, highlighted_chant)
    r = []
    r << 'highlighted' if chant == highlighted_chant

    if chant.simple_copy?
      r << 'simple_copy'
    elsif chant.copy?
      r << 'copy'
    end

    r.join ' '
  end
end
