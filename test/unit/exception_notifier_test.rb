require File.dirname(__FILE__) + "/../test_helper"

class DummyController < ApplicationController; end

class ExceptionNotifierTest < Test::Unit::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    
    @request = ActionController::TestRequest.new
    @request.request_uri = "/foo/bar/baz"
    
    @exception = NoMethodError.new
    
    ExceptionNotifier.email_from ||= 'from@digitalpulp.com'
    ExceptionNotifier.email_to ||= 'to@digitalpulp.com'
  end
  
  def test_notification
    @exception.set_backtrace(caller)
    response = ExceptionNotifier.create_notification(@exception, DummyController.new, @request)

    assert_match %r{#{@exception.class.name}}, response.body
    assert_match %r{#{@request.request_uri}}, response.body
    
    assert_equal ExceptionNotifier.email_from, response.from.first
    assert_equal ExceptionNotifier.email_to, response.to.first
  end
end