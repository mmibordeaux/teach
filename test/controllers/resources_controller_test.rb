require 'test_helper'

class ResourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @resource = resources(:one)
  end

  test "should get index" do
    get resources_url
    assert_response :success
  end

  test "should get new" do
    get new_resource_url
    assert_response :success
  end

  test "should create resource" do
    assert_difference('Resource.count') do
      post resources_url, params: { resource: { code: @resource.code, code_apogee: @resource.code_apogee, description: @resource.description, hours_cm: @resource.hours_cm, hours_td: @resource.hours_td, hours_tp: @resource.hours_tp, label: @resource.label, semester_id: @resource.semester_id } }
    end

    assert_redirected_to resource_url(Resource.last)
  end

  test "should show resource" do
    get resource_url(@resource)
    assert_response :success
  end

  test "should get edit" do
    get edit_resource_url(@resource)
    assert_response :success
  end

  test "should update resource" do
    patch resource_url(@resource), params: { resource: { code: @resource.code, code_apogee: @resource.code_apogee, description: @resource.description, hours_cm: @resource.hours_cm, hours_td: @resource.hours_td, hours_tp: @resource.hours_tp, label: @resource.label, semester_id: @resource.semester_id } }
    assert_redirected_to resource_url(@resource)
  end

  test "should destroy resource" do
    assert_difference('Resource.count', -1) do
      delete resource_url(@resource)
    end

    assert_redirected_to resources_url
  end
end
