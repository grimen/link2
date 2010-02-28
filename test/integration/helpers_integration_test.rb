# encoding: utf-8
require 'test/test_helper'

# TODO: Write integration tests for helpers.
class HelpersIntegrationTest < ActionController::IntegrationTest

  test 'Link2 + Rails = ♥' do
    visit '/'
    assert_response :success
    assert_template 'home/index'

    assert_contain "WIN"
    #assert_match /xxx/, response.body
  end

end