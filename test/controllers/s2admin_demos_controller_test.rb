require 'test_helper'

class S2adminDemosControllerTest < ActionController::TestCase
  setup do
    @s2admin_demo = s2admin_demos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:s2admin_demos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create s2admin_demo" do
    assert_difference('S2adminDemo.count') do
      post :create, s2admin_demo: { content_type: @s2admin_demo.content_type, default_id: @s2admin_demo.default_id, description: @s2admin_demo.description, query: @s2admin_demo.query, service_name: @s2admin_demo.service_name, src_type: @s2admin_demo.src_type, timestamp: @s2admin_demo.timestamp, type: @s2admin_demo.type }
    end

    assert_redirected_to s2admin_demo_path(assigns(:s2admin_demo))
  end

  test "should show s2admin_demo" do
    get :show, id: @s2admin_demo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @s2admin_demo
    assert_response :success
  end

  test "should update s2admin_demo" do
    patch :update, id: @s2admin_demo, s2admin_demo: { content_type: @s2admin_demo.content_type, default_id: @s2admin_demo.default_id, description: @s2admin_demo.description, query: @s2admin_demo.query, service_name: @s2admin_demo.service_name, src_type: @s2admin_demo.src_type, timestamp: @s2admin_demo.timestamp, type: @s2admin_demo.type }
    assert_redirected_to s2admin_demo_path(assigns(:s2admin_demo))
  end

  test "should destroy s2admin_demo" do
    assert_difference('S2adminDemo.count', -1) do
      delete :destroy, id: @s2admin_demo
    end

    assert_redirected_to s2admin_demos_path
  end
end
