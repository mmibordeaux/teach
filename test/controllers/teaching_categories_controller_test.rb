require 'test_helper'

class TeachingCategoriesControllerTest < ActionController::TestCase
  setup do
    @teaching_category = teaching_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:teaching_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create teaching_category" do
    assert_difference('TeachingCategory.count') do
      post :create, teaching_category: { label: @teaching_category.label }
    end

    assert_redirected_to teaching_category_path(assigns(:teaching_category))
  end

  test "should show teaching_category" do
    get :show, id: @teaching_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @teaching_category
    assert_response :success
  end

  test "should update teaching_category" do
    patch :update, id: @teaching_category, teaching_category: { label: @teaching_category.label }
    assert_redirected_to teaching_category_path(assigns(:teaching_category))
  end

  test "should destroy teaching_category" do
    assert_difference('TeachingCategory.count', -1) do
      delete :destroy, id: @teaching_category
    end

    assert_redirected_to teaching_categories_path
  end
end
