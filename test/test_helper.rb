require 'test/unit'
require 'rubygems'
require 'mocha'
# Load the environment
unless defined? RADIANT_ROOT
  ENV["RAILS_ENV"] = "test"
  require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/environment"
end
require "#{RADIANT_ROOT}/test/test_helper"