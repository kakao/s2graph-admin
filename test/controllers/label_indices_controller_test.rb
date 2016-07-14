require 'test_helper'

class LabelIndicesControllerTest < ActionController::TestCase
  setup do
    @label_index = label_indices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:label_indices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create label_index" do
    assert_difference('LabelIndex.count') do
      post :create, label_index: { formulars: @label_index.formulars, label_id: @label_index.label_id, meta_seqs: @label_index.meta_seqs, name: @label_index.name, seq: @label_index.seq }
    end

    assert_redirected_to label_index_path(assigns(:label_index))
  end

  test "should show label_index" do
    get :show, id: @label_index
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @label_index
    assert_response :success
  end

  test "should update label_index" do
    patch :update, id: @label_index, label_index: { formulars: @label_index.formulars, label_id: @label_index.label_id, meta_seqs: @label_index.meta_seqs, name: @label_index.name, seq: @label_index.seq }
    assert_redirected_to label_index_path(assigns(:label_index))
  end

  test "should destroy label_index" do
    assert_difference('LabelIndex.count', -1) do
      delete :destroy, id: @label_index
    end

    assert_redirected_to label_indices_path
  end
end
