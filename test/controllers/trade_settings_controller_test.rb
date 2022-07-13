require "test_helper"

class TradeSettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get trade_settings_edit_url
    assert_response :success
  end

  test "should get update" do
    get trade_settings_update_url
    assert_response :success
  end
end
