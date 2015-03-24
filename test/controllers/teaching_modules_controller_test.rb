require 'test_helper'

class TeachingModulesControllerTest < ActionController::TestCase
  setup do
    @teaching_module = teaching_modules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:teaching_modules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create teaching_module" do
    assert_difference('TeachingModule.count') do
      post :create, teaching_module: { code: @teaching_module.code, coefficient: @teaching_module.coefficient, content: @teaching_module.content, hours: @teaching_module.hours, how_to: @teaching_module.how_to, label: @teaching_module.label, objectives: @teaching_module.objectives, semester_id: @teaching_module.semester_id, teaching_category_id: @teaching_module.teaching_category_id, teaching_subject_id: @teaching_module.teaching_subject_id, teaching_unit_id: @teaching_module.teaching_unit_id, what_next: @teaching_module.what_next }
    end

    assert_redirected_to teaching_module_path(assigns(:teaching_module))
  end

  test "should show teaching_module" do
    get :show, id: @teaching_module
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @teaching_module
    assert_response :success
  end

  test "should update teaching_module" do
    patch :update, id: @teaching_module, teaching_module: { code: @teaching_module.code, coefficient: @teaching_module.coefficient, content: @teaching_module.content, hours: @teaching_module.hours, how_to: @teaching_module.how_to, label: @teaching_module.label, objectives: @teaching_module.objectives, semester_id: @teaching_module.semester_id, teaching_category_id: @teaching_module.teaching_category_id, teaching_subject_id: @teaching_module.teaching_subject_id, teaching_unit_id: @teaching_module.teaching_unit_id, what_next: @teaching_module.what_next }
    assert_redirected_to teaching_module_path(assigns(:teaching_module))
  end

  test "should destroy teaching_module" do
    assert_difference('TeachingModule.count', -1) do
      delete :destroy, id: @teaching_module
    end

    assert_redirected_to teaching_modules_path
  end
end
