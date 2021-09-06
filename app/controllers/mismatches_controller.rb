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
    ParentChildMismatch.unresolved.find(params[:id]).update!(resolved_at: Time.now)

    redirect_back
  end
end
