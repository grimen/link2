# encoding: utf-8
require 'rubygems'

gem 'test-unit', '1.2.3'
require 'test/unit'
require 'leftright'

require 'active_support'
require 'action_controller'
require 'active_record'

require 'active_support/test_case'
require 'action_view/test_case'

# Support.
Dir[File.join(File.dirname(__FILE__), *%w[support ** *.rb]).to_s].each { |f| require f }

# Schema.
ActiveRecord::Schema.define(:version => 1) do
  create_table :fraggles do |t|
    t.string  :name
    t.integer :craziness
    t.string  :hair_color
  end

  create_table :cool_aids do |t|
    t.string  :name
    t.decimal :strength
  end
end

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
