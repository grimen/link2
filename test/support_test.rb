# encoding: utf-8
require 'test_helper'

class SupportTest < ActiveSupport::TestCase

  def setup
  end

  test "#find_resource_class: should find proper class based on class, class instance, or (symbol) name" do
    assert_nil ::Link2::Support.find_resource_class(nil)

    assert_equal ::Fraggle, ::Link2::Support.find_resource_class(::Fraggle)
    assert_equal ::Fraggle, ::Link2::Support.find_resource_class(::Fraggle.new)
    assert_equal ::Fraggle, ::Link2::Support.find_resource_class(:fraggle)

    assert_not_equal ::Fraggle, ::Link2::Support.find_resource_class(::Unicorn)
    assert_not_equal ::Fraggle, ::Link2::Support.find_resource_class(::Unicorn.new)
    assert_not_equal ::Fraggle, ::Link2::Support.find_resource_class(:unicorn)
  end

  test "#resource_identifier_class?: should only be true for valid classes" do
    assert ::Link2::Support.resource_identifier_class?(nil)
    assert ::Link2::Support.resource_identifier_class?(:hello)
    assert ::Link2::Support.resource_identifier_class?(::Fraggle)

    assert_not ::Link2::Support.resource_identifier_class?(::Unicorn)
  end

  test "#record_class?: should only be true for record classes" do
    assert ::Link2::Support.record_class?(::Fraggle)

    assert_not ::Link2::Support.record_class?(::Unicorn)
  end

end