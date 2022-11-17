class ApplicationController < ActionController::Base
  before_action :handle_editfial_error

  private

  def handle_editfial_error
    # receiving redirect back from the "editfial" external service
    # with an error message - display it as a flash message
    if params[:editfialError]
      flash[:error] =
        ERB::Util.html_escape(params[:editfialError]) +
        ' ' + view_context.link_to('Retry', retry_open_in_editor_chants_path, method: :post) +
        session.dig(:last_open_in_editor, 'fial')&.yield_self do |fial|
          # hardcoded path, because using the `fial_chants_path` routing helper results in
          # broken constraint error (when passing fial unescaped and it contains a slash)
          # or generates a URL with double-escaped fial (when passing fial already escaped)
          ' ' + view_context.link_to('Visit', '/chants/fial/' + URI.encode_www_form_component(fial))
        end.to_s
      redirect_to request.params.except(:editfialError)
    end
  end
end
