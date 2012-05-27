require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
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
