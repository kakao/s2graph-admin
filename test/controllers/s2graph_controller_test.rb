require 'test_helper'

class S2graphControllerTest < ActionController::TestCase
  test "should get query" do
    get :query
    assert_response :success
  end

  test "should get manage" do
    get :manage
    assert_response :success
  end

  test "should get demo" do
    get :demo
    assert_response :success
  end

end
