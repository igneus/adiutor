module MismatchesHelper
  Tag = ChantsHelper::Tag

  def mismatch_tags(mismatch)
    c = []

    fial = mismatch.child.fial
    if mismatch.simple_copy?
      c << Tag.new('copy simple', fial)
    end
    if ChildParentComparison.auto_verifiable?(FIAL.parse(fial))
      c << Tag.new('auto-verifiable', fial)
    end

    c
  end
end
