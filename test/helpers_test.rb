# encoding: utf-8
require 'test_helper'

class HelpersTest < ActionView::TestCase

  include Link2::Helpers

  def setup
    ::I18n.locale = :en

     @mookey = ::Fraggle.create(:name => 'Mookey')
     @mookeys_cool_aid = ::CoolAid.create(:name => 'Super-tasty')
  end

  # link({}, {})

  test "link() should raise error" do
    assert_raise(::ArgumentError) { link }
  end

  # link(x, {}, {})

  test "link(url) should render link_to(url, url)" do
    assert_equal link_to('http://example.com', 'http://example.com'), link('http://example.com')
    assert_equal link_to('/posts?by=date', '/posts?by=date'), link('/posts?by=date')
  end

  test "link(label) should render link_to(str_label, '#')" do
    assert_equal link_to('Hello', '#'), link('Hello')
  end

  test "link(:action) should render link_to(t(:action, ...), url_for(:action => :action, ...)), auto-detecting resource" do
    swap ::Link2, :i18n_scopes => ['link.{{action}}'] do
      # assert_equal link_to("New Fraggle"), link(:new)
      assert_raise(::Link2::NotImplementedYetError) { link(:new) }
    end
  end

  test "link(:mapping) should render link_to(t(:mapping, ...), url_for_mapping(:mapping, ...)), auto-detecting resource" do
    swap ::Link2, :i18n_scopes => ['link.{{action}}'] do
      assert_equal link_to("Home", '/'), link(:home)

      swap ::Link2, :action_mappings => {:secret => '/secret'} do
        assert_equal link_to("Secret", '/secret'), link(:secret)
      end
    end
  end

  test "link(@resource) should render link_to(t(:show, ...), @object)" do
    swap ::Link2, :i18n_scopes => ['link.{{action}}'] do
      assert_equal link_to("Show", "/fraggles/#{@mookey.id}"), link(@mookey)
      # assert_equal link_to("Show", "?"), link(::Fraggle) # test this stupid case?
    end
  end

  test "link([@parent, @resource]) should render link_to(t(:show, ...), polymorphic_path([@parent, @resource]))" do
    swap ::Link2, :i18n_scopes => ['link.{{action}}'] do
      assert_equal link_to("Show", "/fraggles/#{@mookey.id}/cool_aids/#{@mookeys_cool_aid.id}"), link([@mookey, @mookeys_cool_aid])
    end
  end

  # FINALIZE: link(x, y, {}, {})

  test "link(label, url) should render link_to(label, url)" do
    assert_equal link_to('http://example.com', 'http://example.com'), link('http://example.com', 'http://example.com')
    assert_equal link_to('New', '/posts/new'), link('New', '/posts/new')
  end

  test "link(:action) should render link_to(label, url_for(:action => :action, ...)), auto-detecting resource" do
    swap ::Link2, :i18n_scopes => ['link.{{action}}'] do
      # assert_equal link_to("New Fraggle!!"), link("New Fraggle!!", :new)
      assert_raise(::Link2::NotImplementedYetError) { link("New Fraggle!!", :new) }
    end
  end

  test "link(label, action) should render link_to(label, url_for_mapping(:mapping, ...)), auto-detecting resource" do
    swap ::Link2, :i18n_scopes => ['link.{{action}}'] do
      assert_equal link_to("Home!!", '/'), link("Home!!", :home)

      swap ::Link2, :action_mappings => {:secret => '/secret'} do
        assert_equal link_to("Damn you!!", '/secret'), link("Damn you!!", :secret)
      end
    end
  end

  test "link(:action, Resource) should render link_to(t(:action, ...), url_for(:action => :action, ...))" do
    swap ::Link2, :i18n_scopes => ['link.{{action}}'] do
      assert_equal link_to("New", "/fraggles/new"), link(:new, ::Fraggle)
    end
  end

  test "link(:action, @resource) should render link_to(t(:action, ...), url_for(:action => :action, ...))" do
    swap ::Link2, :i18n_scopes => ['link.{{action}}'] do
      # Non-RESTful-route, basic case.
      assert_equal link_to("New", "/fraggles/new?id=#{@mookey.id}"), link(:new, @mookey)
      # REST-case.
      assert_equal link_to("Edit", "/fraggles/#{@mookey.id}/edit"), link(:edit, @mookey)
    end
  end

  test "link(:action, [@parent, @resource]) should render link_to(t(:action, ...), polymorphic_path([@parent, @resource]), :action => :action)" do
    swap ::Link2, :i18n_scopes => ['link.{{action}}'] do
      # assert_equal link_to("Edit", "/fraggles/#{@mookey.id}/cool_aids/#{@mookeys_cool_aid.id}/edit"), link(:edit, [@mookey, @mookeys_cool_aid])
      assert_raise(::Link2::NotImplementedYetError) {  link(:edit, [@mookey, @mookeys_cool_aid]) }
    end
  end

  # link(x, y,  z, {}, {})

  test "link(label, action, resource)" do
    assert_equal link_to("Newish", "/fraggles/new"), link("Newish", :new, ::Fraggle)
    assert_equal link_to("Editish", "/fraggles/#{@mookey.id}/edit"), link("Editish", :edit, @mookey)
  end

  test "js_link should not be implemented (yet)" do
    assert_raise(::Link2::NotImplementedYetError) { js_link(:alert, 'alert("New");', {}, {}) }
    assert_raise(::Link2::NotImplementedYetError) { js_button(:alert, 'alert("New");', {}, {}) }
  end

  test "ajax_link should not be implemented (yet)" do
    assert_raise(::Link2::NotImplementedYetError) { ajax_link(:home, {}, {}) }
    assert_raise(::Link2::NotImplementedYetError) { ajax_button(:home, {}, {}) }
  end

end