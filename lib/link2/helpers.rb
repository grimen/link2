# encoding: utf-8

module Link2
  module Helpers

    include ::Link2::Brain

    def self.included(base)
      include JavascriptLinkHelpers
    end

    # Enhanced +link_to+ helper.
    #
    # TODO: Documentation for this helper. For now the README should be sufficient.
    #
    def link(*args, &block)
      args = self.link_to_args(*args)
      link_to(*args)
    end
    alias :link2 :link

    # Enhanced +button_to+ helper.
    #
    # == Usage/Examples:
    #
    # (See +link+ - identical except for passed +button_to+-options)
    #
    def button(*args, &block)
      args = self.link_to_args(*args)
      button_to(*args)
    end
    alias :button2 :button

    # Rails 3-deprecations - unless +prototype_legacy_helper+-plugin.

    module JavascriptLinkHelpers
      def js_link(*args)
        raise ::Link2::NotImplementedYetError
      end

      def js_button(*args)
        raise ::Link2::NotImplementedYetError
      end

      def ajax_link(*args)
        raise ::Link2::NotImplementedYetError
      end
      alias :remote_link :ajax_link

      def ajax_button(*args)
        raise ::Link2::NotImplementedYetError
      end
      alias :remote_button :ajax_button
    end

  end
end
