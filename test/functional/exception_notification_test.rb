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
    Page.expects(:find_error_page).with(404).returns(mock(:render => '404 template'))
    @response.expects(:body=).with('404 template')
    get :show_page, :url => "/"
    assert_response :missing
  end
  
  def test_rescue_action_in_public_should_send_notification_when_500
    exception = NoMethodError.new
    @controller.expects(:show_page).raises(exception)
    ExceptionNotifier.expects(:deliver_notification)
    Page.expects(:find_error_page).with(500).returns(mock(:render => '500 template'))
    @response.expects(:body=).with('500 template')
    get :show_page, :url => "/"
    assert_response :error
  end
  
  def test_500_internal_server_error_page_with_tags
    # TODO
    # set up an InternalServerError page with a body that has "<r:breadcrumbs/> or <r:url/> in it"
    # status_500(nil) should raise an exception
    # status_500 should no longer raise an exception
    # status_500(@request) should not raise an exception
  end

end