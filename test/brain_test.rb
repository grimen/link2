# encoding: utf-8
require 'test_helper'

class BrainTest < ActionView::TestCase

  include ::Link2::Brain

  def setup
    ::I18n.locale = :en

    @mookey = ::Fraggle.create(:name => 'Mookey')
  end

  test "#resource_identifier_class?: should only be true for valid classes" do
    assert resource_identifier_class?(nil)
    assert resource_identifier_class?(:hello)
    assert resource_identifier_class?(::Fraggle)

    assert_not resource_identifier_class?(::Unicorn)
  end

  test "#record_class?: should only be true for record classes" do
    assert record_class?(::Fraggle)

    assert_not record_class?(::Unicorn)
  end

  test "#controller_name_for_resource: should return controller name based on resource" do
    assert_equal 'fraggles', controller_name_for_resource(::Fraggle)
    assert_equal 'fraggles', controller_name_for_resource(::Fraggle.new)
    assert_equal 'fraggles', controller_name_for_resource(:fraggle)
  end

  test "#controller_name_for_resource: should return current controller if no resource is specified or is nil" do
    # Current: TestController
    assert_equal 'test', controller_name_for_resource(nil)
  end

  test "#localized_label: should pass current controller to I18n options" do
    swap ::Link2, :i18n_scopes => ['{{controller}}.links.{{action}}'] do
      store_translations :en, {:fraggles => {:links => {:hello => "Wassup?!"}}} do
        assert_equal "Wassup?!", localized_label(:hello, ::Fraggle)
      end
    end
  end

  test "#label_and_url_for_resource: should parse a label and url from a object (e.g. @post)" do
    store_translations :en, {:links => {:show => "Show {{resource}}"}} do
      assert_equal ["Show fraggle", fraggle_path(@mookey)], label_and_url_for_resource(@mookey)
    end
  end

  test "#label_and_url_for_resource: should parse a label and url from a object (e.g. @post) with respect to to_s-value" do
    store_translations :en, {:links => {:show => "Show {{name}}"}} do
      @mookey.class_eval do
        def to_s
          ""
        end
      end
      assert_equal ["Show fraggle", fraggle_path(@mookey)], label_and_url_for_resource(@mookey)

      @mookey.class_eval do
        def to_s
          self.name
        end
      end
      assert_equal ["Show Mookey", fraggle_path(@mookey)], label_and_url_for_resource(@mookey)
    end
  end

  test "#label_and_url_for_resource: should parse correct label and url from a polymorphic args (e.g. [@user, :blog, @post])" do
    @mookeys_cool_aid = ::CoolAid.create(:name => 'Super-tasty')

    store_translations :en, {:links => {:show => "Show {{name}}"}} do
      @mookeys_cool_aid.class_eval do
        def to_s
          self.name
        end
      end

      assert_equal ["Show Super-tasty", fraggle_cool_aid_path(@mookey, @mookeys_cool_aid)], label_and_url_for_resource([@mookey, @mookeys_cool_aid])
    end
  end

  test "#url_for_args: should use explicitly passed url if any" do
    assert_equal '/posts', url_for_args(:new, '/posts')
    assert_equal '/', url_for_args(:back, '/')
  end

  test "#url_for_args: should generate a url based on action only if mapping for this action exists" do
    assert_equal '/', url_for_args(:home)
    assert_equal :back, url_for_args(:back) # fix this to handle session[:return_to] in proc.
  end

  test "#url_for_args: should generate a url based on action and resource" do
    # FIXME: stub(:session).returns({:return_to => '/'})

    self.expects(:controller_name_for_resource).with(::Fraggle).returns('fraggles')
    self.expects(:controller_name_for_resource).with(:fraggle).returns('fraggles')

    assert_equal '/fraggles/new', url_for_args(:new, :fraggle)
    assert_equal '/fraggles/new', url_for_args(:new, ::Fraggle)

    self.expects(:controller_name_for_resource).with(@mookey).returns('fraggles').twice

    assert_equal "/fraggles/new?id=#{@mookey.id}", url_for_args(:new, @mookey)
    assert_equal "/fraggles/#{@mookey.id}/edit", url_for_args(:edit, @mookey)
  end

  # NOTICE: #link_to_args tested fully in HelpersTest as helpers are sort of identical.

end