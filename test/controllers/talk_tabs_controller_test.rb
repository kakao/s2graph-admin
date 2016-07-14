require 'test_helper'

class TalkTabsControllerTest < ActionController::TestCase
  setup do
    @talk_tab = talk_tabs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:talk_tabs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create talk_tab" do
    assert_difference('TalkTab.count') do
      post :create, talk_tab: {  }
    end

    assert_redirected_to talk_tab_path(assigns(:talk_tab))
  end

  test "should show talk_tab" do
    get :show, id: @talk_tab
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @talk_tab
    assert_response :success
  end

  test "should update talk_tab" do
    patch :update, id: @talk_tab, talk_tab: {  }
    assert_redirected_to talk_tab_path(assigns(:talk_tab))
  end

  test "should destroy talk_tab" do
    assert_difference('TalkTab.count', -1) do
      delete :destroy, id: @talk_tab
    end

    assert_redirected_to talk_tabs_path
  end
end
