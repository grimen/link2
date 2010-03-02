# encoding: utf-8
begin
  require 'active_support'
rescue LoadError
  gem 'activesupport'
  require 'active_support'
end

begin
  require 'action_view'
rescue LoadError
  gem 'actionpack'
  require 'action_view'
end

module Link2

  autoload :Brain,    'link2/brain'
  autoload :Helpers,  'link2/helpers'
  autoload :I18n,     'link2/i18n'
  autoload :Support,  'link2/support'
  autoload :VERSION,  'link2/version'

  # include ::ActionController::UrlWriter

  # Default URL value; if none can be assumed. Useful value for prototyping.
  DEFAULT_LINK = '#'

  # Default lookup scope if none is set.
  DEFAULT_I18N_SCOPE = [:links]

  # Default I18n lookup scopes if none are set.
  DEFAULT_I18N_SCOPES = [
    '{{model}}.links.{{action}}',
    'links.{{action}}'
  ]

  Error = Class.new(::StandardError)
  NotImplementedYetError = Class.new(::NotImplementedError)

  # TODO: Make aware of named routes.
  # include ::ActionController::UrlWriter # don't work as expected here (isolated run), but works in Rails app =S
  #
  # Don't work even if Rails API docs tells so... 8(
  # http://api.rubyonrails.org/classes/ActionController/UrlWriter.html
  # ActionController::UrlWriter.root_path

  # Default action mappings: Link value shortcuts sort of.
  # FIXME:
  # DEFAULT_ACTION_MAPPINGS = {
  #   :home => lambda { '/' }, # TODO: Allow named routes, e.g. root_path
  #   :back => lambda { |url| url || options[:session][:return_to] || :back }
  # }
  DEFAULT_ACTION_MAPPINGS = {
    :home => lambda { '/' }, # TODO: Allow named routes, e.g. root_path
    :back => lambda { |url| url || :back }
  }

  # I18n lookup scopes in ascending order of priority.
  # Used for scoped I18n translations based on model, action, etc., for flexability.
  mattr_accessor :i18n_scopes
  @@i18n_scopes = DEFAULT_I18N_SCOPES

  # Action mappings - a.k.a. "link value shortcuts" - that should be recognized.
  mattr_accessor :action_mappings
  @@action_mappings = DEFAULT_ACTION_MAPPINGS

  # DOM selectors for easier manipulation of Link2 linksusing CSS/JavaScript.
  mattr_accessor :dom_selectors
  @dom_selectors = true

  class << self

    # Yield self for configuration block:
     #
     #   Link2.setup do |config|
     #     config.i18n_scope = [:actions]
     #   end
     #
     def setup
       yield(self)
     end

     # Finds any existing "action mapping" based on a mapping key (custom action).
     #
     # == Example/Usage:
     #
     #   Link2.action_mappings[:back] = lambda { |url| url || session[:return_to] || :back }
     #
     #   url_for_mapping(:back)
     #   # => session[:return_to] || :back
     #
     #   url_for_mapping(:back, "/unicorns")
     #   # => "/unicorns"
     #
     def url_for_mapping(action, custom_url = nil, options = {})
       expression = ::Link2.action_mappings[action]
       if expression.is_a?(Proc)
         expression.arity == 0 ? expression.call : expression.call(custom_url)
       else
         expression
       end
     end

   end
end

# Make I18n aware of our default locale.
I18n.load_path.unshift File.expand_path(File.join(File.dirname(__FILE__), 'link2', 'locales', 'en.yml'))

# Add extended ActionView behaviour.
ActionView::Base.class_eval do
  include ::Link2::Helpers
end
