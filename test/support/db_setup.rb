# encoding: utf-8

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

ActiveSupport::TestCase.class_eval do
  # self.use_transactional_fixtures = true
  # self.use_instantiated_fixtures  = false
end