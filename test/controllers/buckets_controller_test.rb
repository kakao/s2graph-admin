require 'test_helper'

class BucketsControllerTest < ActionController::TestCase
  setup do
    @bucket = buckets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:buckets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bucket" do
    assert_difference('Bucket.count') do
      post :create, bucket: { api_path: @bucket.api_path, experiment_id: @bucket.experiment_id, http_verb: @bucket.http_verb, impression_id: @bucket.impression_id, is_graph_query: @bucket.is_graph_query, request_body: @bucket.request_body, timeout: @bucket.timeout, traffic_ratios: @bucket.traffic_ratios, uuid_key: @bucket.uuid_key, uuid_mods: @bucket.uuid_mods, uuid_placeholder: @bucket.uuid_placeholder }
    end

    assert_redirected_to bucket_path(assigns(:bucket))
  end

  test "should show bucket" do
    get :show, id: @bucket
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bucket
    assert_response :success
  end

  test "should update bucket" do
    patch :update, id: @bucket, bucket: { api_path: @bucket.api_path, experiment_id: @bucket.experiment_id, http_verb: @bucket.http_verb, impression_id: @bucket.impression_id, is_graph_query: @bucket.is_graph_query, request_body: @bucket.request_body, timeout: @bucket.timeout, traffic_ratios: @bucket.traffic_ratios, uuid_key: @bucket.uuid_key, uuid_mods: @bucket.uuid_mods, uuid_placeholder: @bucket.uuid_placeholder }
    assert_redirected_to bucket_path(assigns(:bucket))
  end

  test "should destroy bucket" do
    assert_difference('Bucket.count', -1) do
      delete :destroy, id: @bucket
    end

    assert_redirected_to buckets_path
  end
end
