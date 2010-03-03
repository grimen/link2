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
        if arg.is_a?(NilClass)
          nil
        elsif arg.is_a?(Symbol)
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

      def extract_resource(resource)
        resource.compact! if resource.is_a?(Array)
        [resource].flatten.last
      end

      # Check if the specified object is a valid resource identifier class. Used
      # for detecting current resource based on controller, action, etc.
      #
      def resource_identifier_class?(object)
        (object.is_a?(NilClass) || object.is_a?(Symbol) || self.record_class?(object))
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
        self.record_object?(object_or_class)
      end

      # Check if a specified objec is a record instance.
      #
      # == Usage/Examples:
      #
      #   record_object?(Post.new)  # if: Post < ActiveRecord::Base, or similar.
      #     # => true
      #
      #   record_object?(Post)
      #     # => false
      #
      def record_object?(object)
        object.respond_to?(:new_record?)
      end
    end

  end
end