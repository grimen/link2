# encoding: utf-8

module Link2
  module Brain

    AutoDetectionFailed = Class.new(::ArgumentError)
    NilArgument = Class.new(::ArgumentError)

    URL_PATH_REGEX = /\//
    CLASS_INSTANCE_STRING = /\#\<.*\:0x.*\>/

    LINK_TO_OPTION_KEYS = [:method, :confirm, :popup, :html_options].freeze
    BUTTON_TO_OPTION_KEYS = [:method, :confirm, :disabled].freeze
    IGNORED_OPTION_KEYS = (LINK_TO_OPTION_KEYS + BUTTON_TO_OPTION_KEYS).uniq

    POLYMORPHIC_OPTION_KEYS = [:action, :routing_type]

    protected

      # The Link2 helpers brain: Extracts any additional known info about
      # based on the specified helper arguments to make smart assumptions.
      #
      # NOTE: This method is quite messy, but the different conditionals makes
      # it tricky to refactor much more for now until DSL is very settled.
      # The comments give guidelines on what assumptions is being made in each case.
      #
      def link_to_args(*args)
        args.unshift(capture(&block)) if block_given?

        html_options = args.pop if args.last.is_a?(Hash)
        url_options = args.pop if args.last.is_a?(Hash)

        raise NilArgument, "Passed argument is nil: #{args.inspect}." if args.any? { |arg| arg.nil? }

        case args.size
        when 0
          raise ArgumentError, "No arguments specified. A least specify action or url."
        when 1
          if args.first.is_a?(String)
            if args.first =~ URL_PATH_REGEX
              # link 'http://example.com'  => link_to 'http://example.com', 'http://example.com'
              label = url = args.shift
            else
              # link "Hello"  => link_to 'Hello', '#'
              url = ::Link2::DEFAULT_LINK
              label = args.shift
            end
          elsif args.first.is_a?(Symbol)
            # link :new  => link_to I18n.t(:new, ...), new_{auto_detected_resource}_path
            # link :back  => link_to I18n.t(:back, ...), (session[:return_to] || :back)
            action = args.shift
            label = self.localized_label(action, resource = nil, url_options)
            resource = false if html_options && html_options.key?(:onclick) # false => do not auto-detect
            url = self.url_for_args(action, resource, url_options)
          elsif args.first.is_a?(Object)
            # link @user  => link_to I18n.t(:show, ...), user_path(@user)
            # link [:admin, @user]  => link_to I18n.t(:show, ...), admin_user_path(@user)
            resource = args.shift
            label, url = self.label_and_url_for_resource(resource, url_options)
          else
            raise ArgumentError, "Invalid 1st argument: #{args.inspect}"
          end
        when 2
          if args.first.is_a?(String)
            if args.second.is_a?(String)
              # link "Hello", hello_path  => link_to "Hello", hello_path
              label, url = args.slice!(0..1)
            elsif args.second.is_a?(Symbol) && ::Link2.url_for_mapping(args.second)
              # link "Start", :home  => link_to I18n.t(:start, ...), root_path
              # link "Cancel", :back  => link_to I18n.t(:cancel, ...), :back
              label, action = args.slice!(0..1)
              url = self.url_for_args(action, resource = nil, url_options)
            elsif ::Link2::Support.resource_identifier_class?(args.second)
              # link "New", :new  => link_to "New", new_{auto_detected_resource}_path
              # link "<<", :back  => link_to "<<", (session[:return_to] || :back)
              label, action = args.slice!(0..1)
              url = self.url_for_args(action, resource = nil, url_options)
            else
              raise ArgumentError, "Invalid 2nd argument: #{args.inspect}"
            end
          elsif args.first.is_a?(Symbol)
            if args.second.is_a?(String)
              # link :new, new_post_path  => link_to I18n.t(:new, ...), new_post_path
              # link :back, root_path  => link_to I18n.t(:back, ...), (session[:return_to] || :back)
              action, url = args.slice!(0..1)
              label = self.localized_label(action, resource = nil, url_options)
            elsif args.second.is_a?(Symbol) && ::Link2.url_for_mapping(args.second)
              # link :start, :home  => link_to I18n.t(:start, ...), root_path
              # link :cancel, :back  => link_to I18n.t(:cancel, ...), :back
              key, action = args.slice!(0..1)
              label = self.localized_label(key, resource = nil, url_options)
              url = self.url_for_args(action, resource, url_options)
            elsif ::Link2::Support.resource_identifier_class?(args.second)
              # link :new, Post  => link_to I18n.t(:new, ...), new_post_path
              # link :edit, @post  => link_to I18n.t(:edit, ...), edit_post_path(@post)
              # link :show, [:admin, @user]  => link_to I18n.t(:show, ...), admin_user_path(@user)
              action, resource = args.slice!(0..1)
              label = self.localized_label(action, resource, url_options)
              url = self.url_for_args(action, resource, url_options)
            elsif args.second.is_a?(Array)
              # link :kick, [:admin, @user]  => link_to I18n.t(:show, ...), admin_user_path(@user)
              action, resource = args.slice!(0..1)
              url_options_with_action = url_options.present? ? url_options.merge(:action => action) : {:action => action}
              label, url = self.label_and_url_for_resource(resource, url_options_with_action)
            else
              raise ArgumentError, "Invalid 2nd argument: #{args.inspect}"
            end
          else
            raise ArgumentError, "Invalid 1st argument: #{args.inspect}"
          end
        when 3
          if args.first.is_a?(String)
            if args.second.is_a?(Symbol)
              if ::Link2::Support.resource_identifier_class?(args.third)
                # link "New", :new, Post  => link_to "New", new_post_path
                # link "Edit", :edit, @post  => link_to "Edit", edit_post_path(@post)
                label, action, resource = args.slice!(0..2)
                url = self.url_for_args(action, resource, url_options)
              elsif args.third.is_a?(Array)
                # link "Kick", :kick, [:admin, @user]  => link_to I18n.t(:show, ...), admin_user_path(@user)
                label, action, resource = args.slice!(0..2)
                url_options_with_action = url_options.present? ? url_options.merge(:action => action) : {:action => action}
                url = self.label_and_url_for_resource(resource, url_options_with_action).last
              else
                raise ArgumentError, "Invalid 3rd argument: #{args.inspect}"
              end
            else
              raise ArgumentError, "Invalid 2nd argument: #{args.inspect}"
            end
          else
            raise ArgumentError, "Invalid 1st argument: #{args.inspect}"
          end
        else # when else
          raise ArgumentError, "Invalid number of arguments: #{args.inspect}."
        end

        if ::Link2.dom_selectors == true
          html_options = self.merge_link2_dom_selectors(action, resource, html_options)
        end

        args << url_options if url_options
        args << html_options if html_options

        [label, url, *args]
      end

      # Extracts a label and a url for a (polymorphic) resource.
      # Partly based on - and accepts same options as - Rails core helper +polymorphic_url+.
      #
      # == Usage/Example:
      #
      #   @post = Post.find(1)
      #
      #   label_and_url_for_resource(@post)
      #     # => t(:show, ...), '/posts/1'
      #
      #   label_and_url_for_resource([:admin, @post], :action => :edit)
      #     # => t(:show, ...), '/admin/posts/1/edit'
      #
      #   label_and_url_for_resource(@post, :hello => 'World')
      #     # => t(:show, :hello => 'World', ...), '/posts/1'
      #
      # See documentation on +polymorphic_url+ for available core options.
      #
      def label_and_url_for_resource(*args)
        options = args.extract_options!.dup
        resource = args.first

        url_for_options = options.slice(*POLYMORPHIC_OPTION_KEYS).reverse_merge(:routing_type => :path)
        i18n_options = options.except(url_for_options.keys)

        last_resource = ::Link2::Support.extract_resource(resource)
        action = options.delete(:action)
        url_for_options[:action] = [:show, :index].include?(action) ? nil : action

        label = self.localized_label(action || :show, last_resource, i18n_options)
        url = polymorphic_url(resource, url_for_options)

        [label, url]
      end

      # Generates a proper URL based on specified arguments.
      # Partly based on - and accepts same options as - Rails core helper +url_for+.
      #
      # Note: Overrides +:controller+, +:action+, and +:id+ options.
      #
      # == Usage/Example:
      #
      #   @post = Post.find(1)
      #
      #   url_for_args(:new, Post)
      #     # => '/posts/new'
      #
      #   url_for_args(:edit, @post)
      #     # => '/posts/1/edit'
      #
      #   url_for_args(:home)
      #     # => '/'
      #
      # See documentation on +url_for+ for available core options.
      #
      def url_for_args(*args)
        options = args.extract_options!.dup
        action, resource = args

        if resource == false # javascript onclick; disable resource auto-detection
          ::Link2::DEFAULT_LINK
        elsif resource.is_a?(String) # url
          resource
        elsif resource.nil? && url = ::Link2.url_for_mapping(action, resource) # mapping
          url
        else
          resource ||= self.auto_detect_resource || self.auto_detect_collection
          if resource.nil?
            raise ::Link2::Brain::AutoDetectionFailed,
              "Auto-detection of resource or collection failed for args: #{[action, resource].inspect}."
          end

          options[:controller] ||= "/%s" % self.controller_name_for_resource(resource)
          options[:action] = action
          options[:id] = resource.id if !resource.is_a?(Class) && ::Link2::Support.record_class?(resource)

          url_for(options.except(*IGNORED_OPTION_KEYS))
        end
      end

      # Helper for translating labels; merging any additional required translation info
      # for the current template instance.
      #
      def localized_label(action, resource, options = {})
        options ||= {}
        i18n_options = options.merge(:controller => self.controller_name_for_resource(resource), :name => self.human_name_for_resource(resource))
        ::Link2::I18n.t(action, resource, i18n_options)
      end

      # Parse controller name based for a specified resource.
      #
      # == Example/Usage:
      #
      #   # Rails routing:  map.resources :posts
      #
      #   controller_name_for_resource
      #     # => "#{@template.controller.controller_name}"
      #
      #   controller_name_for_resource(:post)
      #     # => "posts"
      #
      #   controller_name_for_resource(Post)
      #     # => "posts"
      #
      #   controller_name_for_resource(@post)
      #     # => "posts"
      #
      #   controller_name_for_resource([@post_1, @post_2])
      #     # => "posts"
      #
      def controller_name_for_resource(resource_or_collection = nil)
        if resource_or_collection
          if ::Link2::Support.record_collection?(resource_or_collection)
            resource_or_collection.first.class.name.tableize
          else
            resource_class = ::Link2::Support.find_resource_class(resource_or_collection)
            resource_class.name.tableize if ::Link2::Support.record_class?(resource_class)
          end
        end || self.controller.controller_name
      end
      # When no resource is passed +current_controller_name+ makes more sense.
      alias :current_controller_name :controller_name_for_resource

      # Parse human resource name for a specified resource.
      #
      # == Example/Usage:
      #
      #   human_name_for_resource(@post)
      #     # => "post"
      #
      #   human_name_for_resource(@post)
      #     # => "post"
      #
      #   class Post < ActiveRecord::Base
      #     def to_s
      #       self.title
      #     end
      #   end
      #
      #   human_name_for_resource(Post.create(:title => "Hello"))
      #     # => "Hello"
      #
      def human_name_for_resource(resource)
        return nil unless resource_class = ::Link2::Support.find_resource_class(resource)
        raise ArgumentError unless ::Link2::Support.record_class?(resource_class)

        if ::Link2::Support.record_object?(resource)
          # Skip any ugly default to_s-value:
          custom_name = resource.to_s =~ CLASS_INSTANCE_STRING ? ::Link2::Support.human_name_for(resource_class).downcase : resource.to_s
        end
        custom_name = ::Link2::Support.human_name_for(resource_class).downcase if custom_name.blank?
        custom_name
      end

      # Auto-detect current view resource instance based on expected ivar-name.
      #
      def auto_detect_resource
        if self.respond_to?(:resource) # InheritedResources pattern
          self.resource
        else
          self.instance_variable_get(:"@#{self.current_controller_name.singularize}") # @post
        end
      rescue
        nil
      end

      # Auto-detect current view resource collection instance based on expected ivar-name.
      #
      def auto_detect_collection
        if self.respond_to?(:collection) # InheritedResources pattern
          self.collection
        else
          self.instance_variable_get(:"@#{self.current_controller_name.pluralize}") # @posts
        end
      rescue
        nil
      end

      # Attach Link2 semantic DOM selector attributes (attributes "id" and "class") based on
      # action and resource - if any can be parsed.
      #
      # == Usage/Examples:
      #
      #   attach_link2_dom_selectors(:new, Post, {})
      #     # => {:class => "new post"}
      #
      #   attach_link2_dom_selectors(:new, Post, {:id => "one", :class => "two"})
      #     # => {:id => "one", :class => "new post two"}
      #
      #   attach_link2_dom_selectors(:new, @post_14, {})
      #     # => {:class => "edit post id_14"}
      #
      #   attach_link2_dom_selectors(:new, @post_14, {:id => "one", :class => "two"})
      #     # => {:id => "one", :class => "edit post two"}
      #
      def merge_link2_dom_selectors(action, resource = nil, html_options = {})
        html_options ||= {}
        link2_attributes = self.link2_attrbutes_for(action, resource)

        html_options[:class] = [link2_attributes[:class],html_options[:class]].compact.join(' ')
        html_options[:class] = nil if html_options[:class].blank?

        html_options
      end

      # Generate semantic Link2 HTML attributes.
      #
      # See: +merge_link2_dom_selectors+.
      #
      def link2_attrbutes_for(action, resource = nil)
        resource_class = ::Link2::Support.find_resource_class(resource)

        resource_name_dom_class = resource_class.name.underscore if resource_class.present?
        resource_id_dom_class = "id_#{resource.id}" if ::Link2::Support.record_object?(resource)
        dom_class = [action.to_s, resource_name_dom_class, resource_id_dom_class].compact.join(' ')

        {:class => dom_class}
      end

  end
end
