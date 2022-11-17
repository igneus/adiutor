class ApplicationController < ActionController::Base
  before_action :handle_editfial_error

  private

  def handle_editfial_error
    # receiving redirect back from the "editfial" external service
    # with an error message - display it as a flash message
    if params[:editfialError]
      flash[:error] = view_context.render(
        'chants/open_in_editor_error',
        message: params[:editfialError],
        last_fial: session.dig(:last_open_in_editor, 'fial')
      )

      redirect_to request.params.except(:editfialError)
    end
  end
end
