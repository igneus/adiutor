class MismatchesController < ApplicationController
  def index
    @mismatches =
      ParentChildMismatch.unresolved.order(:id)
  end

  def show
    @mismatch = ParentChildMismatch.unresolved.find(params[:id])
    @next = ParentChildMismatch.unresolved.next_to(@mismatch)
  end

  def resolve
    mismatch = ParentChildMismatch.unresolved.find(params[:id])
    mismatch.update!(resolved_at: Time.now)

    up_next = ParentChildMismatch.unresolved.next_to(mismatch)

    redirect_to mismatch_path(up_next)
  end
end
