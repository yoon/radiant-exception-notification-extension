require_dependency 'application'

module ExceptionNotification
  
  ERROR_TYPES = {404 => FileNotFoundPage, 500 => InternalServerErrorPage}
  
  def self.included(base)
    base.class_eval do
      alias_method_chain :rescue_action_in_public, :notification
      alias_method_chain :rescue_action_locally, :template
    end
  end
  
  def rescue_action_in_public_with_notification(exception)
    case exception
    when ActiveRecord::RecordNotFound, ActionController::UnknownController, ActionController::UnknownAction, ActionController::RoutingError
      status_404(request)
    else
      status_500(request)
      ExceptionNotifier.deliver_notification(exception, self, request)
    end
  end
  
  def rescue_action_locally_with_template(exception)
    unless Radiant::Config['debug?']
      case exception
        when ActiveRecord::RecordNotFound, ActionController::UnknownController, ActionController::UnknownAction, ActionController::RoutingError
          status_404(request)
        else 
          status_500(request)
          ExceptionNotifier.deliver_notification(exception, self, request)
      end
    else
      rescue_action_locally_without_template exception
    end
  end
  
  private
  
  def status_404(request = generic_request)
    headers["Status"] = "404 Not Found"
    page = Page.find_error_page(404)
    page.request = request
    response.body = page.render
  end
  
  def status_500(request = generic_request)
    headers["Status"] = "500 Internal Server Error"
    page = Page.find_error_page(500)
    page.request = request
    response.body = page.render
  end
  
  def generic_request
    g = ActionController::AbstractRequest.new
    g.relative_url_root = "/"
  end

end