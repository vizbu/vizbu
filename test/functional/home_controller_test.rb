require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'index contains a search form' do
    get_html :index

    #doc = Nokogiri::HTML(@response.body)
    #p doc.xpath('//form').count
    #doc.xpath('//form').each do |elem|
    #  puts elem.inspect[0..20]
    #  puts elem.to_xml
    #end

    form = assert_xpath('//form[ @action = "/search" ]')
    assert_xpath form, './/input[ @name = "q" and @value = "" ]'
    #puts form.to_xml
  end

  test "should get search" do
    # FIXME get :search
    #assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end

end
