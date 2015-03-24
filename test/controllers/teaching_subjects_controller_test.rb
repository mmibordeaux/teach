require 'test_helper'

class TeachingSubjectsControllerTest < ActionController::TestCase
  setup do
    @teaching_subject = teaching_subjects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:teaching_subjects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create teaching_subject" do
    assert_difference('TeachingSubject.count') do
      post :create, teaching_subject: { label: @teaching_subject.label, teaching_unit_id: @teaching_subject.teaching_unit_id }
    end

    assert_redirected_to teaching_subject_path(assigns(:teaching_subject))
  end

  test "should show teaching_subject" do
    get :show, id: @teaching_subject
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @teaching_subject
    assert_response :success
  end

  test "should update teaching_subject" do
    patch :update, id: @teaching_subject, teaching_subject: { label: @teaching_subject.label, teaching_unit_id: @teaching_subject.teaching_unit_id }
    assert_redirected_to teaching_subject_path(assigns(:teaching_subject))
  end

  test "should destroy teaching_subject" do
    assert_difference('TeachingSubject.count', -1) do
      delete :destroy, id: @teaching_subject
    end

    assert_redirected_to teaching_subjects_path
  end
end
