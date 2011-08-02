require 'test_helper'

class TerminalControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "should interpret" do
    post 'interpret', :id => 1, 'code' => "puts 123"
    assert true
  end
end
