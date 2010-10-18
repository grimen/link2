# encoding: utf-8
require 'test_helper'

class I18nTest < ActiveSupport::TestCase

  def setup
    ::I18n.locale = :en
    ::Link2.i18n_scopes = ['links.{{action}}']
  end

  test "i18n: should load default translations automatically" do
    options = {:scope => 'links', :resource => 'post', :resources => 'posts'}

    ::I18n.backend.reload!

    assert_equal "Home", ::I18n.t(:home, options)
    assert_equal "Back", ::I18n.t(:back, options)

    assert_equal "New post", ::I18n.t(:new, options)
    assert_equal "Edit post", ::I18n.t(:edit, options)
    assert_equal "Delete post", ::I18n.t(:delete, options)
    assert_equal "Show post", ::I18n.t(:show, options)
    assert_equal "Index of posts", ::I18n.t(:index, options)
  end

  test "i18n: should substitute scopes with parsed values for: controller, action, resource, resources" do
    dummie_scopes = ['{{controller}}.{{models}}.{{model}}.{{action}}.label', 'links.{{action}}']
    expected_substitution = [:'fraggles.fraggles.fraggle.new.label', :'links.new']
    expected_substitution_underscored = [:'fraggles.cool_aids.cool_aid.new.label', :'links.new']

    swap ::Link2, :i18n_scopes => dummie_scopes do
      assert_raise(::Link2::I18n::ScopeInterpolationError) { ::Link2::I18n.send(:substituted_scopes_for, :new, ::Fraggle) }

      assert_nothing_raised(::KeyError) { ::Link2::I18n.send(:substituted_scopes_for, :new, ::Fraggle, :controller => 'fraggles') }
      assert_equal expected_substitution, ::Link2::I18n.send(:substituted_scopes_for, :new, ::Fraggle, :controller => 'fraggles')
      assert_equal expected_substitution_underscored, ::Link2::I18n.send(:substituted_scopes_for, :new, ::CoolAid, :controller => 'fraggles')
    end
  end

  test "i18n: should be able to translate action without any options" do
    swap ::Link2, :i18n_scopes => ['links.{{action}}'] do
      i18n_options = {:scope => 'links', :resource => 'fraggle', :resources => 'fraggles'}

      assert_equal ::I18n.t(:new, i18n_options), ::Link2::I18n.t(:new, ::Fraggle)
      assert_equal ::I18n.t(:new, i18n_options), ::Link2::I18n.t(:new, ::Fraggle.new)
      assert_equal ::I18n.t(:new, i18n_options), ::Link2::I18n.t(:new, :fraggle)
    end
  end

  test "i18n: should be able to translate action with respect to any valid " do
    swap ::Link2, :i18n_scopes => ['links.{{action}}'] do
      store_translations :en, {:links => {:shout => 'Hello %{nick}!'}} do
        i18n_options = {:scope => 'links', :nick => 'Mokey'}

        assert_equal ::I18n.t(:shout, i18n_options), ::Link2::I18n.t(:shout, ::Fraggle.new, :nick => 'Mokey')
      end
    end
  end

  test "i18n: should not interpolate values for any reserved interpolation keys" do
    swap ::Link2, :i18n_scopes => ['links.{{action}}'] do
      store_translations :en, {:links => {:shout => 'Hello %{scope}!'}} do
        i18n_options = {:scope => 'links', :name => 'Mokey'}

        assert_raise(I18n::ReservedInterpolationKey) { ::Link2::I18n.t(:shout, ::Fraggle.new, :scope => 'Mokey') }
      end
    end
  end

end