require 'test_helper'

class Admin::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_subscriptions_index_url
    assert_response :success
  end

  test "should get export" do
    get admin_subscriptions_export_url
    assert_response :success
  end

end
