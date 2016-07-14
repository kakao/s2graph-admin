require 'test_helper'

class S2mlControllerTest < ActionController::TestCase
  test "should get intro" do
    get :intro
    assert_response :success
  end

  test "should get engines" do
    get :engines
    assert_response :success
  end

  test "should get history" do
    get :history
    assert_response :success
  end

end
