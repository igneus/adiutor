module ChantsHelper
  def listing_item_classes(chant)
    c = []
    c << 'chant-with-quality-notice' if chant.marked_for_revision?
    c << 'chant-with-edited-lyrics' if chant.lyrics_edited?

    c.empty? ? nil : c
  end

  def lyrics_diff(chant)
    Diffy::Diff
      .new(chant.textus_approbatus, chant.lyrics)
      .to_s(:html)
  end
end
