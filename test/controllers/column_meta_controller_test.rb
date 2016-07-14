require 'test_helper'

class ColumnMetaControllerTest < ActionController::TestCase
  setup do
    @column_metum = column_meta(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:column_meta)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create column_metum" do
    assert_difference('ColumnMetum.count') do
      post :create, column_metum: { column_id: @column_metum.column_id, data_type: @column_metum.data_type, name: @column_metum.name, seq: @column_metum.seq }
    end

    assert_redirected_to column_metum_path(assigns(:column_metum))
  end

  test "should show column_metum" do
    get :show, id: @column_metum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @column_metum
    assert_response :success
  end

  test "should update column_metum" do
    patch :update, id: @column_metum, column_metum: { column_id: @column_metum.column_id, data_type: @column_metum.data_type, name: @column_metum.name, seq: @column_metum.seq }
    assert_redirected_to column_metum_path(assigns(:column_metum))
  end

  test "should destroy column_metum" do
    assert_difference('ColumnMetum.count', -1) do
      delete :destroy, id: @column_metum
    end

    assert_redirected_to column_meta_path
  end
end
