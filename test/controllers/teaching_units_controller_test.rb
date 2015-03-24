require 'test_helper'

class TeachingUnitsControllerTest < ActionController::TestCase
  setup do
    @teaching_unit = teaching_units(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:teaching_units)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create teaching_unit" do
    assert_difference('TeachingUnit.count') do
      post :create, teaching_unit: { number: @teaching_unit.number }
    end

    assert_redirected_to teaching_unit_path(assigns(:teaching_unit))
  end

  test "should show teaching_unit" do
    get :show, id: @teaching_unit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @teaching_unit
    assert_response :success
  end

  test "should update teaching_unit" do
    patch :update, id: @teaching_unit, teaching_unit: { number: @teaching_unit.number }
    assert_redirected_to teaching_unit_path(assigns(:teaching_unit))
  end

  test "should destroy teaching_unit" do
    assert_difference('TeachingUnit.count', -1) do
      delete :destroy, id: @teaching_unit
    end

    assert_redirected_to teaching_units_path
  end
end
