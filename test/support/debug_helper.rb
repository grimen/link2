# encoding: utf-8
require 'i18n'

module Link2
  module DebugHelper

    def debug_routes
      ::ActionController::Routing::Routes.named_routes.each do |name, route|
        puts "%20s: %s" % [name, route]
      end
    end

  end
end

ActiveSupport::TestCase.class_eval do
  include Link2::DebugHelper
end