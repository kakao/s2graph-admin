require 'test_helper'

class LabelsControllerTest < ActionController::TestCase
  setup do
    @label = labels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:labels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create label" do
    assert_difference('Label.count') do
      post :create, label: { compressionAlgorithm: @label.compressionAlgorithm, consistency_level: @label.consistency_level, hbase_table_name: @label.hbase_table_name, hbase_table_ttl: @label.hbase_table_ttl, is_async: @label.is_async, is_directed: @label.is_directed, label: @label.label, schema_version: @label.schema_version, service_id: @label.service_id, service_name: @label.service_name, src_column_name: @label.src_column_name, src_column_type: @label.src_column_type, src_service_id: @label.src_service_id, tgt_column_name: @label.tgt_column_name, tgt_column_type: @label.tgt_column_type, tgt_service_id: @label.tgt_service_id }
    end

    assert_redirected_to label_path(assigns(:label))
  end

  test "should show label" do
    get :show, id: @label
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @label
    assert_response :success
  end

  test "should update label" do
    patch :update, id: @label, label: { compressionAlgorithm: @label.compressionAlgorithm, consistency_level: @label.consistency_level, hbase_table_name: @label.hbase_table_name, hbase_table_ttl: @label.hbase_table_ttl, is_async: @label.is_async, is_directed: @label.is_directed, label: @label.label, schema_version: @label.schema_version, service_id: @label.service_id, service_name: @label.service_name, src_column_name: @label.src_column_name, src_column_type: @label.src_column_type, src_service_id: @label.src_service_id, tgt_column_name: @label.tgt_column_name, tgt_column_type: @label.tgt_column_type, tgt_service_id: @label.tgt_service_id }
    assert_redirected_to label_path(assigns(:label))
  end

  test "should destroy label" do
    assert_difference('Label.count', -1) do
      delete :destroy, id: @label
    end

    assert_redirected_to labels_path
  end
end
