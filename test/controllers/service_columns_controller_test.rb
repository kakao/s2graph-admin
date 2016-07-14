require 'test_helper'

class ServiceColumnsControllerTest < ActionController::TestCase
  setup do
    @service_column = service_columns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:service_columns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create service_column" do
    assert_difference('ServiceColumn.count') do
      post :create, service_column: { column_name: @service_column.column_name, column_type: @service_column.column_type, schema_version: @service_column.schema_version, service_id: @service_column.service_id }
    end

    assert_redirected_to service_column_path(assigns(:service_column))
  end

  test "should show service_column" do
    get :show, id: @service_column
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @service_column
    assert_response :success
  end

  test "should update service_column" do
    patch :update, id: @service_column, service_column: { column_name: @service_column.column_name, column_type: @service_column.column_type, schema_version: @service_column.schema_version, service_id: @service_column.service_id }
    assert_redirected_to service_column_path(assigns(:service_column))
  end

  test "should destroy service_column" do
    assert_difference('ServiceColumn.count', -1) do
      delete :destroy, id: @service_column
    end

    assert_redirected_to service_columns_path
  end
end
