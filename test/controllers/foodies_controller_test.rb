require 'test_helper'

class FoodiesControllerTest < ActionController::TestCase
  setup do
    @foody = foodies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:foodies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create foody" do
    assert_difference('Foody.count') do
      post :create, foody: { address: @foody.address, category: @foody.category, description: @foody.description, photos: @foody.photos, title: @foody.title }
    end

    assert_redirected_to foody_path(assigns(:foody))
  end

  test "should show foody" do
    get :show, id: @foody
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @foody
    assert_response :success
  end

  test "should update foody" do
    patch :update, id: @foody, foody: { address: @foody.address, category: @foody.category, description: @foody.description, photos: @foody.photos, title: @foody.title }
    assert_redirected_to foody_path(assigns(:foody))
  end

  test "should destroy foody" do
    assert_difference('Foody.count', -1) do
      delete :destroy, id: @foody
    end

    assert_redirected_to foodies_path
  end
end
