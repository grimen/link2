# encoding: utf-8

module Link2
  module Brain

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

        #puts [url_options, html_options].compact.inspect

        case args.size
        when 0
          raise "No arguments specified. A least specify action or url."
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
            label = self.localized_label(action, url_options)
            resource = nil # TODO: auto-detect resource.
            url = self.url_for_args(action, resource, url_options)
          elsif args.first.is_a?(Object)
            # link @user  => link_to I18n.t(:show, ...), user_path(@user)
            # link [:admin, @user]  => link_to I18n.t(:show, ...), admin_user_path(@user)
            resource = args.shift
            label, url = self.label_and_url_for_resource(resource, url_options)
          else
            raise "Invalid 1st argument: #{args.inspect}"
          end
        when 2
          if args.first.is_a?(String)
            if args.second.is_a?(String)
              # link "Hello", hello_path  => link_to "Hello", hello_path
              label, url = args.slice!(0..1)
            elsif self.resource_identifier_class?(args.second)
              # link "New", :new  => link_to "New", new_{auto_detected_resource}_path
              # link "<<", :back  => link_to "<<", (session[:return_to] || :back)
              label, action = args.slice!(0..1)
              resource = nil # TODO: auto-detect resource.
              url = self.url_for_args(action, resource, url_options)
            else
              raise "Invalid 2nd argument: #{args.inspect}"
            end
          elsif args.first.is_a?(Symbol)
            # TODO: Implement this:
            if args.second.is_a?(Array)
              raise ::Link2::NotImplementedYetError, "case link(:action, [...]) not yet supported. Need to refactor some stuff."
            end
            # TODO: Cleanup.
            if self.resource_identifier_class?(args.second)
              # link :new, Post  => link_to I18n.t(:new, ...), new_post_path
              # link :edit, @post  => link_to I18n.t(:edit, ...), edit_post_path(@post)
              # link :show, [:admin, @user]  => link_to I18n.t(:show, ...), admin_user_path(@user)
              # link :back, root_path  => link_to I18n.t(:back, ...), (session[:return_to] || :back)
              action, resource = args.slice!(0..1)
              label = self.localized_label(action, resource, url_options)
              url = self.url_for_args(action, resource, url_options)
            else
              raise "Invalid 2nd argument: #{args.inspect}"
            end
          else
            raise "Invalid 1st argument: #{args.inspect}"
          end
        when 3
          if args.first.is_a?(String)
            if args.second.is_a?(Symbol)
              if self.resource_identifier_class?(args.third)
                # link "New", :new, Post  => link_to "New", new_post_path
                # link "Edit", :edit, @post  => link_to "Edit", edit_post_path(@post)
                label, action, resource = args.slice!(0..2)
                url = self.url_for_args(action, resource, url_options)
              else
                raise "Invalid 3rd argument: #{args.inspect}"
              end
            else
              raise "Invalid 2nd argument: #{args.inspect}"
            end
          else
            raise "Invalid 1st argument: #{args.inspect}"
          end
        else
          raise "Invalid number of arguments: #{args.inspect}."
        end
        args << url_options if url_options
        args << html_options if html_options
        [label, url, *args]
      rescue => e
        raise ::ArgumentError, e
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
      def label_and_url_for_resource(resource, options = {})
        options ||= {}
        resource.compact! if resource.is_a?(Array)
        last_resource = [resource].flatten.last
        url_for_options = options.slice(*POLYMORPHIC_OPTION_KEYS).reverse_merge(:routing_type => :path)
        i18n_options = options.except(url_for_options.keys)

        # Skip any ugly default to_s-value.
        custom_name = last_resource.to_s =~ CLASS_INSTANCE_STRING ? last_resource.class.human_name.downcase : last_resource.to_s
        custom_name = last_resource.class.human_name.downcase if custom_name.blank?

        label = self.localized_label(:show, last_resource.class, i18n_options.merge(:name => custom_name))
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

        if resource.nil?
          url = ::Link2.url_for_mapping(action, resource) rescue nil
          if url
            url
          else
            raise ::Link2::NotImplementedYetError,
              "Resource needs to be specified for non-mapped actions; auto-detection of resource(s) not implemented yet."
          end
        elsif resource.is_a?(String)
          resource
        else
          options[:controller] ||= self.controller_name_for_resource(resource)
          options[:action] = action
          options[:id] = resource.id if !resource.is_a?(Class) && self.record_class?(resource)

          url_for(options.except(*IGNORED_OPTION_KEYS))
        end
      end

      # Helper for translating labels; merging any additional required translation info
      # for the current template instance.
      #
      def localized_label(action, resource, options = {})
        options ||= {}
        i18n_options = options.merge(:controller => self.controller_name_for_resource(resource))
        ::Link2::I18n.t(action, resource, i18n_options)
      end

      # Get controller name based for a specified resource.
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
      def controller_name_for_resource(resource = nil)
        resource_class = ::Link2::Support.find_resource_class(resource)
        if self.record_class?(resource_class)
          resource_class.to_s.tableize # rescue nil
        end || self.controller.controller_name
      end

      # Check if the specified object is a valid resource identifier class. Used
      # for detecting current resource based on controller, action, etc.
      #
      def resource_identifier_class?(object)
        object.is_a?(NilClass) || object.is_a?(Symbol) || self.record_class?(object)
      end

      # Check if a specified objec is a record class type.
      #
      # == Usage/Examples:
      #
      #   record_class?(ActiveRecord::Base)
      #     # => true
      #
      #   record_class?(String)
      #     # => false
      #
      def record_class?(object_or_class)
        return false if object_or_class == NilClass || object_or_class.is_a?(NilClass)
        object_or_class = object_or_class.new if object_or_class.is_a?(Class)
        object_or_class.respond_to?(:new_record?)
      end

  end
end