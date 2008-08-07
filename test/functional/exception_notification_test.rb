require File.dirname(__FILE__) + "/../test_helper"

class ExceptionNotificationTest < Test::Unit::TestCase
  
  def setup
    @controller = SiteController.new
    class << @controller
      def rescue_action(e)
        rescue_action_in_public(e)
      end
    end
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    ActionController::Base.consider_all_requests_local = false
    ExceptionNotifier.stubs(:deliver_notification)
  end
  
  def teardown
    ActionController::Base.consider_all_requests_local = true
  end
  
  def test_module_inclusion
    assert ApplicationController.included_modules.include?(ExceptionNotification)
  end
  
  def test_rescue_action_in_public_should_render_when_404
    exception = ActiveRecord::RecordNotFound.new
    ExceptionNotifier.expects(:deliver_notification).never
    @controller.expects(:show_page).raises(exception)
    Page.expects(:find_error_page).with(404).returns(mock(:render => '404 template', :request= => @request))
    @response.expects(:body=).with('404 template')
    get :show_page, :url => "/"
    assert_response :missing
  end
  
  def test_rescue_action_in_public_should_send_notification_when_500
    exception = NoMethodError.new
    @controller.expects(:show_page).raises(exception)
    ExceptionNotifier.expects(:deliver_notification)
    Page.expects(:find_error_page).with(500).returns(mock(:render => '500 template', :request= => @request))
    @response.expects(:body=).with('500 template')
    get :show_page, :url => "/"
    assert_response :error
  end
  
  def test_rendered_page_has_access_to_request
    url = PagePart.new(:name => 'body', :content => '<r:url/>')
    page = Page.new(:parts => [url], :slug => '/bogus-url')
    @controller.expects(:show_page).raises(NoMethodError.new)
    Page.stubs(:find_error_page).with(500).returns(page)
    get :show_page
    assert_match(/bogus-url/, @response.body)
  end

end