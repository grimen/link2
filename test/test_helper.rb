# encoding: utf-8
require 'rubygems'

ENV['RAILS_ENV'] = 'test'
TEST_ORM = (ENV['ORM'] || :active_record).to_sym

# ORM / Schema.
require File.join(File.dirname(__FILE__), 'orm', TEST_ORM.to_s)

gem 'test-unit', '1.2.3'
require 'test/unit'

begin
  require 'leftright'
rescue LoadError
end

# require 'active_support'
# require 'action_controller'
# require 'active_record'

require 'mocha'
require 'webrat'

require 'active_support/test_case'
require 'action_view/test_case'

# Support.
Dir[File.join(File.dirname(__FILE__), *%w[support ** *.rb]).to_s].each { |f| require f }

# Models.
class Fraggle < ActiveRecord::Base
end
class CoolAid < ActiveRecord::Base
end
class Unicorn
end

# Controllers.
class FragglesController < ActionController::Base
end
class CoolAidController < ActionController::Base
end

# Routes.
ActionController::Routing::Routes.draw do |map|
  map.resources :fraggles, :has_many => :cool_aids
  map.resource :cool_aid

  map.root :controller => 'fraggles'
end

require 'link2'
