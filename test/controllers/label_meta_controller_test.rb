require 'test_helper'

class LabelMetaControllerTest < ActionController::TestCase
  setup do
    @label_metum = label_meta(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:label_meta)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create label_metum" do
    assert_difference('LabelMetum.count') do
      post :create, label_metum: { data_type: @label_metum.data_type, default_value: @label_metum.default_value, label_id: @label_metum.label_id, name: @label_metum.name, seq: @label_metum.seq, used_in_index: @label_metum.used_in_index }
    end

    assert_redirected_to label_metum_path(assigns(:label_metum))
  end

  test "should show label_metum" do
    get :show, id: @label_metum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @label_metum
    assert_response :success
  end

  test "should update label_metum" do
    patch :update, id: @label_metum, label_metum: { data_type: @label_metum.data_type, default_value: @label_metum.default_value, label_id: @label_metum.label_id, name: @label_metum.name, seq: @label_metum.seq, used_in_index: @label_metum.used_in_index }
    assert_redirected_to label_metum_path(assigns(:label_metum))
  end

  test "should destroy label_metum" do
    assert_difference('LabelMetum.count', -1) do
      delete :destroy, id: @label_metum
    end

    assert_redirected_to label_meta_path
  end
end
