# encoding: utf-8
require 'test_helper'

class SupportTest < ActiveSupport::TestCase

  def setup
  end

  test "#find_resource_class: should find proper class based on class, class instance, or (symbol) name" do
    assert_equal ::Fraggle, ::Link2::Support.find_resource_class(::Fraggle)
    assert_equal ::Fraggle, ::Link2::Support.find_resource_class(::Fraggle.new)
    assert_equal ::Fraggle, ::Link2::Support.find_resource_class(:fraggle)

    assert_not_equal ::Fraggle, ::Link2::Support.find_resource_class(::Unicorn)
    assert_not_equal ::Fraggle, ::Link2::Support.find_resource_class(::Unicorn.new)
    assert_not_equal ::Fraggle, ::Link2::Support.find_resource_class(:unicorn)
  end

end