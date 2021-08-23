module ChantsHelper
  def listing_item_classes(chant)
    c = []
    c << 'chant-with-quality-notice' if chant.marked_for_revision?
    c << 'chant-with-edited-lyrics' if chant.textus_approbatus.present?

    c.empty? ? nil : c
  end
end
