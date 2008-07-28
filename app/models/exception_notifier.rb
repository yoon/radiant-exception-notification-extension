require 'pp'

class ExceptionNotifier < ActionMailer::Base
  
  cattr_accessor :email_from, :email_to
    
  def notification(exception, controller, request)
    time = Time.new
    from          ExceptionNotifier.email_from
    recipients    ExceptionNotifier.email_to
    subject       "Rails exception on #{request.env["HTTP_HOST"]} \@ #{time.to_s :db} » #{exception.class.name} occurred in #{controller.controller_name}\##{controller.action_name}"
    body          :exception => exception, :request => request,
                  :controller => controller, :host => request.env["HTTP_HOST"],
                  :backtrace => sanitize_backtrace(exception.backtrace),
                  :rails_root => rails_root, :time => time

    content_type  'text/plain'
  end
  
  
  private
    # cribbed from the original Rails exception_notification plugin: http://github.com/rails/exception_notification/tree/master
    def sanitize_backtrace(trace)
      re = Regexp.new(/^#{Regexp.escape(rails_root)}/)
      trace.map { |line| Pathname.new(line.gsub(re, "[RAILS_ROOT]")).cleanpath.to_s }
    end
  
    def rails_root
      @rails_root ||= Pathname.new(RAILS_ROOT).cleanpath.to_s
    end
  
end