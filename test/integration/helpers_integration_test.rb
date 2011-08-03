# encoding: utf-8
require 'test_helper'

class HelpersIntegrationTest < ActionController::IntegrationTest

  test 'Link2 + Rails = ♥' do
    visit '/'
    assert_response :success
    assert_template 'home/index'

    # puts response.body.inspect

    assert_contain "WIN"
  end

end