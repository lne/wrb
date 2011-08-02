require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "route" do
    assert_routing('/', :controller => 'welcome', :action => 'index')
  end
end
