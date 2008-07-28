require File.dirname(__FILE__) + "/../test_helper"

class ExceptionNotifierPageTest < Test::Unit::TestCase
  
  def setup
    create_page(Page) do |root|
      create_page(FileNotFoundPage, :parent_id => root.id) do |filenotfound|
        create_page(InternalServerErrorPage, :parent_id => filenotfound.id)
      end
    end
  end
  
  ### Class methods ###
  
  def test_should_return_a_direct_descendent
    assert_equal @file_not_found_page, Page.find_error_page(404)
  end
  
  def test_should_return_a_distant_descendent
    assert_equal @internal_server_error_page, Page.find_error_page(500)
  end
  
  def test_should_return_nil_if_no_error_page_defined
    assert_nil Page.find_error_page(501)
  end
  
  ### Instance methods ###
  
  def test_should_find_self
    assert_equal @file_not_found_page, @file_not_found_page.find_error_page(404)
  end
  
  def test_should_find_child
    assert_equal @internal_server_error_page, @file_not_found_page.find_error_page(500)
  end
  
  def test_should_return_nil_if_neither_self_nor_child
    assert_nil @internal_server_error_page.find_error_page(404)
  end
  
  private
  
    def create_page(klass,attrs={})
      name = klass.name.underscore
      attrs.merge!(:title => name, :slug => name, :breadcrumb => name)
      page = instance_variable_set("@#{name}", klass.create(attrs))
      yield page if block_given?
    end
  
end