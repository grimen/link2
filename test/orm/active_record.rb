# encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'integration', 'rails_app', 'config', 'environment'))
require 'test_help'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

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

  create_table :ponies do |t|
    t.string  :color
  end
end

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end