require "test_helper"

class CoinsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get coins_new_url
    assert_response :success
  end

  test "should get create" do
    get coins_create_url
    assert_response :success
  end

  test "should get edit" do
    get coins_edit_url
    assert_response :success
  end

  test "should get update" do
    get coins_update_url
    assert_response :success
  end

  test "should get index" do
    get coins_index_url
    assert_response :success
  end

  test "should get show" do
    get coins_show_url
    assert_response :success
  end

  test "should get delete" do
    get coins_delete_url
    assert_response :success
  end
end
