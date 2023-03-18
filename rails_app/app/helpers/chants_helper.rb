module ChantsHelper
  Tag = Struct.new(:text, :long_desc)

  def chant_tags(chant, corpus: true,  children: false)
    c = []
    c << Tag.new('quality notice', chant.placet) if chant.marked_for_revision?
    c << Tag.new('favourite') if chant.placet == '*'
    c << Tag.new('edited lyrics') if chant.lyrics_edited?
    if chant.simple_copy?
      c << Tag.new('copy simple', chant.fial)
    elsif chant.fial.present?
      c << Tag.new('copy', chant.fial)
    end

    if chant.children_tree_size&.> 2
      c << Tag.new("#{chant.children_tree_size - 1} children")
    elsif children
      # not done by default, as it requires eager-loaded children or a separate query
      c << Tag.new('has children') unless chant.children.empty?
    end

    c << Tag.new('mismatch') if chant.mismatches.present?
    c << Tag.new('hour missing') if chant.hour_id.nil?
    c << Tag.new('genre missing') if chant.genre_id.nil?

    if corpus
      c << Tag.new(corpus_shortcut(chant.corpus.name), chant.corpus.name + ' corpus')

      c << Tag.new('OP', 'from Dominican books') if chant.book.system_name == 'bsop'
      c << Tag.new('OSB', 'from Monastic books') if %w(bm lhm).include? chant.book.system_name
    end

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

  def quality_notice_button(chant)
    return '' if chant.corpus.system_name != 'in_adiutorium'

    opts = {
      title: "Add quality notice - modifies the source code in the directory specified in the configuration",
      data: {confirm: 'Really add quality notice?'}
    }
    if chant.placet.present?
      opts.update(disabled: true, title: 'already has a quality notice')
    end

    button_to(
      'Non placet',
      add_quality_notice_chant_path(chant),
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
