module ChantsHelper
  def chant_tags(chant)
    c = []
    c << 'quality notice' if chant.marked_for_revision?
    c << 'favourite' if chant.placet == '*'
    c << 'edited lyrics' if chant.lyrics_edited?
    c << 'copy' if chant.fial.present?
    c << 'mismatch' if chant.mismatches.present?
    c << 'hour missing' if chant.hour_id.nil?
    c << 'genre missing' if chant.genre_id.nil?

    c
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
end
