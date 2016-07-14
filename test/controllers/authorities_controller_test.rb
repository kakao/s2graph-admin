require 'test_helper'

class AuthoritiesControllerTest < ActionController::TestCase
  setup do
    @authority = authorities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:authorities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create authority" do
    assert_difference('Authority.count') do
      post :create, authority: { service_id: @authority.service_id, user_id: @authority.user_id }
    end

    assert_redirected_to access_path(assigns(:authority))
  end

  test "should show authority" do
    get :show, id: @authority
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @authority
    assert_response :success
  end

  test "should update authority" do
    patch :update, id: @authority, authority: { service_id: @authority.service_id, user_id: @authority.user_id }
    assert_redirected_to access_path(assigns(:authority))
  end

  test "should destroy authority" do
    assert_difference('Authority.count', -1) do
      delete :destroy, id: @authority
    end

    assert_redirected_to access_path
  end
end
