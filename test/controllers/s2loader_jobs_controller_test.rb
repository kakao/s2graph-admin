require 'test_helper'

class S2loaderJobsControllerTest < ActionController::TestCase
  setup do
    @s2loader_job = s2loader_jobs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:s2loader_jobs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create s2loader_job" do
    assert_difference('S2loaderJob.count') do
      post :create, s2loader_job: { description: @s2loader_job.description, input_dir: @s2loader_job.input_dir, label: @s2loader_job.label, schedule: @s2loader_job.schedule, service: @s2loader_job.service, test_column: @s2loader_job.test_column, test_id: @s2loader_job.test_id }
    end

    assert_redirected_to s2loader_job_path(assigns(:s2loader_job))
  end

  test "should show s2loader_job" do
    get :show, id: @s2loader_job
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @s2loader_job
    assert_response :success
  end

  test "should update s2loader_job" do
    patch :update, id: @s2loader_job, s2loader_job: { description: @s2loader_job.description, input_dir: @s2loader_job.input_dir, label: @s2loader_job.label, schedule: @s2loader_job.schedule, service: @s2loader_job.service, test_column: @s2loader_job.test_column, test_id: @s2loader_job.test_id }
    assert_redirected_to s2loader_job_path(assigns(:s2loader_job))
  end

  test "should destroy s2loader_job" do
    assert_difference('S2loaderJob.count', -1) do
      delete :destroy, id: @s2loader_job
    end

    assert_redirected_to s2loader_jobs_path
  end
end
