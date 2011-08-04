# -*- encoding: utf-8 -*-
require 'rubygems'
require 'bundler'
Bundler.require

ENV['RAILS_ENV'] = 'test'
TEST_ORM = (ENV['ORM'] || :active_record).to_sym unless defined?(TEST_ORM)

# ORM / Schema.
require File.join(File.dirname(__FILE__), 'orm', TEST_ORM.to_s)

require 'test/unit'
require 'mocha'
require 'webrat'
begin
  require 'leftright'
rescue LoadError
end
require 'action_controller'
require 'action_view/test_case'
require 'active_support/test_case'

require 'link2'

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
  map.resources :fraggles, :member => {:kick => :post} do |fraggles|
    fraggles.resources :cool_aids, :member => {:kick => :post}
  end
  map.resource :cool_aid

  map.root :controller => 'fraggles'
end
