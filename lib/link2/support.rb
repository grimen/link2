# encoding: utf-8

module Link2
  module Support

    class << self
      # Get resource class based on name, object, or class.
      #
      # == Example/Usage:
      #
      #   resource_class(:post), resource_class(@post), resource_class(Post)
      #     # => Post, Post, Post
      #
      def find_resource_class(arg)
        if arg.is_a?(Symbol)
          resource_class_name = arg.to_s.singularize.camelize
          resource_class_name.constantize
        elsif arg.is_a?(Class)
          arg
        elsif arg.is_a?(Object)
          arg.class
        else
          arg
        end
      rescue
        raise "No such class: #{resource_class_name}"
      end
    end

  end
end