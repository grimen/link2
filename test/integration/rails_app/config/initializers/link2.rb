Link2.setup do |config|
  # Configure how - and in what order - link labels should be looked up.
  config.i18n_scopes = [
    '{{model}}.links.{{action}}',
    'links.{{action}}'
  ]

  # Configure any custom action mappings.
  config.action_mappings = {
    :home => lambda { '/' },
    :back => lambda { |url| url || :back }
  }
  # TODO: Make procs containing routes work.
  # config.action_mappings = {
  #   :home => lambda { root_path },
  #   :back => lambda { |url| url || session[:return_to] || :back }
  # }
end
