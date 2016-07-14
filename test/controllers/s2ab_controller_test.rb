require 'test_helper'

class S2abControllerTest < ActionController::TestCase
  test "should get list" do
    get :list
    assert_response :success
  end

end
