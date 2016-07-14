require 'test_helper'

class QueriesControllerTest < ActionController::TestCase
  test "should get visualize" do
    get :visualize
    assert_response :success
  end

end
