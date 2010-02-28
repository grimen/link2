# encoding: utf-8

module Link2
  module I18n

    ScopeInterpolationError = Class.new(::Link2::Error)

    VALID_SCOPE_VARIABLES = [:controller, :action, :resource, :resources].freeze
    INTERPOLATION_SYNTAX_PATTERN = /(\\)?\{\{([^\}]+)\}\}/
    RESERVED_KEYS = ::I18n::Backend::Base::RESERVED_KEYS

    class << self

      # Helper method to lookup I18n keys based on a additionally known conditions;
      # such as current action, model, etc.. This makes I18n translations more flexible
      # and maintainable: Bottom-up approach; if no translation is found by first scope;
      # try next scope, etc.
      #
      # == Scoped I18n lookup (default):
      #
      #   1. links.{{resource}}.{{action}}
      #   2. links.{{action}}
      #   ...
      #
      # == Valid value interpolations:
      #
      # * +resource+    - resource humanized name (parsed with I18n if possible), e.g. CaptainMorgan / @captain_morgan => "captain morgan"
      # * +resources+   - pluralized resource humanized name (parsed with I18n if possible), e.g. CaptainMorgan / @captain_morgan => "captain morgans"
      # * +name+        - current resource name to_s-value, e.g. @captain_morgan.to_s => "Captain Morgan with Cola and lime #4"
      #
      def translate_with_scoping(action, resource, options = {})
        raise ArgumentError, "At least action must be specified." unless action.present?
        resource_name = self.localized_resource_class_name(resource)
        i18n_options = options.merge(
          :scope => nil,
          :default => self.substituted_scopes_for(action, resource, options),
          :resource => resource_name,
          :resources => resource_name.pluralize
        )
        key = i18n_options[:default].shift
        i18n_options[:default] << action.to_s.humanize
        ::I18n.t(key, i18n_options)
      end
      alias :translate :translate_with_scoping
      alias :t :translate_with_scoping

      protected

        # Pre-processeses Link2 I18n scopes by interpolating any scoping
        # variables.
        #
        # == Usage/Examples:
        #
        #   ::Link2.i18n_scopes = ['{{models}}.links.{{action}}', '{{controller}}.links.{{action}}', 'links.{{action}}']
        #
        #   substituted_scopes_for(:new, Post.new)
        #     # => Link2::I18n::ScopeInterpolationError
        #
        #   substituted_scopes_for(:new, Post.new, :controller => 'admin')
        #     # => ['posts.links.new', 'admin.links.{new', 'links.new']
        #
        # == Valid lookup scope interpolations:
        #
        # * +model+       - link model name, e.g. CaptainMorgan / @captain_morgan => "captain_morgan"
        # * +models+      - pluralized link model name, e.g. CaptainMorgan / @captain_morgan => "captain_morgans"
        # * +controller+  - current controller name
        # * +action+      - the link action name
        #
        def substituted_scopes_for(action, resource, options = {})
          model_name = self.localized_resource_class_name(resource) # TODO: Should not be localized. Maybe use "model"/"models" to avoid confusion?
          substitutions = options.merge(
            :action => action.to_s.underscore,
            :model => model_name,
            :models => model_name.pluralize
          )

          scopes = ::Link2::i18n_scopes.collect do |i18n_scope|
            i18n_key = i18n_scope.dup
            i18n_key.gsub!(INTERPOLATION_SYNTAX_PATTERN, '%{\2}') # {{hello}} => %{hello}
            begin
              i18n_key = i18n_key % substitutions
            rescue KeyError
              raise ::Link2::I18n::ScopeInterpolationError,
                "Contains a invalid scope-variable: #{i18n_key.inspect}. Valid scope-variables: #{VALID_SCOPE_VARIABLES.join(',')}"
                # "key not found: #{i18n_key.inspect} where #{substitutions.collect { |k,v| "#{k}=#{v.inspect}"}.join(', ')}"
            end
            i18n_key.tr!('/', '.')
            i18n_key.gsub!('..', '.')
            i18n_key.to_sym
          end
          scopes
        end

        # Extracts a localized class name from a resource class/instance/identifier.
        #
        def localized_resource_class_name(resource)
          resource_class = ::Link2::Support.find_resource_class(resource)
          resource_name = resource_class.human_name rescue resource_class.to_s.humanize
          resource_name.underscore
        end

    end

  end
end
