# encoding: utf-8

module Link2
  module AssertionsHelper
    def assert_not(assertion)
      assert !assertion
    end

    def assert_blank(assertion)
      assert assertion.blank?
    end

    def assert_not_blank(assertion)
      assert !assertion.blank?
    end
    alias :assert_present :assert_not_blank

    def assert_no_select(*args)
      assert_raise Test::Unit::AssertionFailedError do
        assert_select(*args)
      end
    end
  end
end

ActiveSupport::TestCase.class_eval do
  include Link2::AssertionsHelper
end
