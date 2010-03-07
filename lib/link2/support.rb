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

      # Extract resource based on resource or collecton of resources.
      #
      # == Usage/Examples:
      #
      #   extract_resource?(nil)
      #     # => nil
      #
      #   extract_resource?([])
      #     # => nil
      #
      #   extract_resource?(@post)
      #     # => @post
      #
      #   extract_resource?([@post_1, @post_2])
      #     # => @post_2
      #
      def extract_resource(resource)
        resource.compact! if resource.is_a?(Array)
        [resource].flatten.last
      end

      # Check if the specified object is a valid resource identifier class. Used
      # for detecting current resource based on controller, action, etc.
      #
      #   resource_identifier_class?(:string)
      #     # => false
      #
      #   resource_identifier_class?(:post)
      #     # => true
      #
      #   resource_identifier_class?(String)
      #     # => false
      #
      #   resource_identifier_class?(Post)
      #     # => true
      #
      #   resource_identifier_class?("")
      #     # => false
      #
      #   resource_identifier_class?(@post)
      #     # => true
      #
      def resource_identifier_class?(object)
        (object.is_a?(Symbol) || self.record_class?(object))
      end

      # Check if passed object is an array for record instances, i.e. "collection".
      # THis assumes all objects in the array is of same kind; makes little sense with mixing
      # different records kinds in a collection, and in such case any auto-detection is hard.
      #
      # == Usage/Examples:
      #
      #   record_collection?([])
      #     # => false
      #
      #   record_collection?(@post)
      #     # => false
      #
      #   record_collection?([@post])
      #     # => true
      #
      #   record_collection?([@post, @article])
      #     # => false
      #
      #   record_collection?([@post, @post])
      #     # => true
      #
      def record_collection?(collection_maybe)
        if collection_maybe.present? && collection_maybe.is_a?(Array)
          collection_maybe.compact.all? { |object| record_object?(object) }
        else
          false
        end
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