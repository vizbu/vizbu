require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'index contains a search form' do

    get_html :index

    form = assert_xpath('//form[ @action = "/search" ]')
    assert_xpath form, './/input[ @name = "q" and @value = "" ]'
  end

  test 'posting a search returns something' do
    post :search, :q => 'frabjous'
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
