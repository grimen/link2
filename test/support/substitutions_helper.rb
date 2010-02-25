# encoding: utf-8
require 'i18n'

module Link2
  module SubstitutionsHelper

    # Execute the block setting the given values and restoring old values after
    # the block is executed.
    def swap(object, new_values)
      old_values = {}
      new_values.each do |key, value|
        old_values[key] = object.send key
        object.send :"#{key}=", value
      end
      yield
    ensure
      old_values.each do |key, value|
        object.send :"#{key}=", value
      end
    end

    def store_translations(locale, translations, &block)
      current_translations = ::I18n.backend.send(:translations).send(:[], locale.to_sym)

      begin
        ::I18n.backend.store_translations locale, translations
        yield
      ensure
        # ::I18n.reload!
      end
    end

  end
end

ActiveSupport::TestCase.class_eval do
  include Link2::SubstitutionsHelper
end
