# encoding: utf-8
require 'test_helper'

class HelpersTest < ActionView::TestCase

  include Link2::Helpers

  ONE_HASH = {:confirm => 'Really?'}
  TWO_HASHES = [{:confirm => 'Really?'}, {:class => 'funny'}]

  def setup
    ::I18n.locale = :en
    ::Link2.dom_selectors = false
    ::Link2.i18n_scopes = [] # Keep it simple - no scoped lookups by default.

    @mookey = ::Fraggle.create(:name => 'Mookey')
    @wembley = ::Fraggle.create(:name => 'Wembley')
    @mookeys_cool_aid = ::CoolAid.create(:name => 'Super-tasty')
  end

  # link({}, {})

  test "link() should raise error" do
    assert_raise(::ArgumentError) { link }
  end

  # link(x, {}, {})

  test "link(url) should render link_to(url, url)" do
    assert_equal link_to('http://example.com', 'http://example.com'), link('http://example.com')
    assert_equal link_to('/posts?by=date', '/posts?by=date'),         link('/posts?by=date')
  end

  test "link(label) should render link_to(label, '#')" do
    assert_equal link_to('Hello', '#'), link('Hello')
  end

  test "link(label_or_action, :onclick => '...') should render link_to_function(label, 'javascript: ...')" do
    if self.respond_to?(:link_to_function) # Note: Deprecated in Rails 3
      assert_equal link_to_function('Hello', 'alert("hello")'), link('Hello', :onclick => 'alert("hello"); return false;')
      assert_equal link_to_function('Hello', 'alert("hello")'), link(:hello, :onclick => 'alert("hello"); return false;')
    end

    assert_equal link_to('Hello', '#', :onclick => 'alert("hello"); return false;'), link('Hello', :onclick => 'alert("hello"); return false;')
    assert_equal link_to('Hello', '#', :onclick => 'alert("hello"); return false;'), link(:hello, :onclick => 'alert("hello"); return false;')
  end

  test "auto-detecting resource: link(:action) should render link_to(t(:action, ...), @resource)" do
    self.expects(:current_controller_name).with(nil).returns('fraggles').at_least_once

    assert_raise(::Link2::Brain::AutoDetectionFailed) do
      link(:show)
    end

    @fraggle = @mookey

    assert_nothing_raised(::Link2::Brain::AutoDetectionFailed) do
      link(:show)
    end

    assert_equal link_to("Show", "/fraggles/#{@fraggle.id}"),               link(:show)
    assert_equal link_to("Show", "/fraggles/#{@fraggle.id}", ONE_HASH),     link(:show, ONE_HASH)
    assert_equal link_to("Show", "/fraggles/#{@fraggle.id}", *TWO_HASHES),  link(:show, *TWO_HASHES)
  end

  test "auto-detecting collection: link(:action) should render link_to(t(:action, ...), @collection)" do
    self.expects(:current_controller_name).with(nil).returns('fraggles').at_least_once

    assert_raise(::Link2::Brain::AutoDetectionFailed) do
      link(:index)
    end

    @fraggles = [@mookey, @wembley]

    assert_nothing_raised(::Link2::Brain::AutoDetectionFailed) do
      link(:index)
    end

    assert_equal link_to("Index", "/fraggles"),               link(:index)
    assert_equal link_to("Index", "/fraggles", ONE_HASH),     link(:index, ONE_HASH)
    assert_equal link_to("Index", "/fraggles", *TWO_HASHES),  link(:index, *TWO_HASHES)
  end

  test "link(:mapping) should render link_to(t(:mapping, ...), url_for_mapping(:mapping, ...)), lookup mapping" do
    assert_equal link_to("Home", '/'),              link(:home)
    assert_equal link_to("Home", '/', ONE_HASH),    link(:home, ONE_HASH)
    assert_equal link_to("Home", '/', *TWO_HASHES), link(:home, *TWO_HASHES)

    swap ::Link2, :action_mappings => {:secret => '/secret'} do
      assert_equal link_to("Secret", '/secret'),              link(:secret)
      assert_equal link_to("Secret", '/secret', ONE_HASH),    link(:secret, ONE_HASH)
      assert_equal link_to("Secret", '/secret', *TWO_HASHES), link(:secret, *TWO_HASHES)
    end
  end

  test "link(@resource) should render link_to(t(:show, ...), @object)" do
    assert_equal link_to("Show", "/fraggles/#{@mookey.id}"),              link(@mookey)
    assert_equal link_to("Show", "/fraggles/#{@mookey.id}", ONE_HASH),    link(@mookey, ONE_HASH)
    assert_equal link_to("Show", "/fraggles/#{@mookey.id}", *TWO_HASHES), link(@mookey, *TWO_HASHES)
    # assert_equal link_to("Show", "?"), link(::Fraggle) # test this stupid case?
  end

  test "link([@parent_resource, @resource]) should render link_to(t(:show, ...), polymorphic_path([@parent_resource, @resource]))" do
    assert_equal link_to("Show", "/fraggles/#{@mookey.id}/cool_aids/#{@mookeys_cool_aid.id}"),              link([@mookey, @mookeys_cool_aid])
    assert_equal link_to("Show", "/fraggles/#{@mookey.id}/cool_aids/#{@mookeys_cool_aid.id}", ONE_HASH),    link([@mookey, @mookeys_cool_aid], ONE_HASH)
    assert_equal link_to("Show", "/fraggles/#{@mookey.id}/cool_aids/#{@mookeys_cool_aid.id}", *TWO_HASHES), link([@mookey, @mookeys_cool_aid], *TWO_HASHES)
  end

  # link(x, y, {}, {})

  test "link(:action, url) should render link_to(t(:action, ...), url)" do
    assert_equal link_to('Home', '/custom-home'), link(:home, '/custom-home')
  end

  test "link(..., :mapping) should render link_to(..., url_for_mapping(:mapping, ...))" do
    assert_nothing_raised(Exception) { link("Home", :home) }
    assert_equal link_to("Home", root_path), link("Home", :home)
    assert_nothing_raised(Exception) { link(:home, :home) }
    assert_equal link_to("Home", root_path), link(:home, :home)

    assert_nothing_raised(Exception) { link("Back", :back) }
    assert_equal link_to("Back", :back), link("Back", :back)
    assert_nothing_raised(Exception) { link(:back, :back) }
    assert_equal link_to("Back", :back), link(:back, :back)
  end

  test "link(label, url) should render link_to(label, url)" do
    assert_equal link_to('New', '/posts/new'),              link('New', '/posts/new')
    assert_equal link_to('New', '/posts/new', ONE_HASH),    link('New', '/posts/new', ONE_HASH)
    assert_equal link_to('New', '/posts/new', *TWO_HASHES), link('New', '/posts/new', *TWO_HASHES)

    assert_equal link_to('http://example.com', 'http://example.com'),               link('http://example.com', 'http://example.com')
    assert_equal link_to('http://example.com', 'http://example.com', ONE_HASH),     link('http://example.com', 'http://example.com', ONE_HASH)
    assert_equal link_to('http://example.com', 'http://example.com', *TWO_HASHES),  link('http://example.com', 'http://example.com', *TWO_HASHES)
  end

  test "link(:action) should render link_to(label, url_for(:action => :action, ...)), auto-detecting resource" do
    # assert_equal link_to("New Fraggle!!"), link("New Fraggle!!", :new)
    assert_raise(::Link2::Brain::AutoDetectionFailed) { link("New Fraggle!!", :new) }
    assert_raise(::Link2::Brain::AutoDetectionFailed) { link("New Fraggle!!", :new, ONE_HASH) }
    assert_raise(::Link2::Brain::AutoDetectionFailed) { link("New Fraggle!!", :new, *TWO_HASHES) }
  end

  test "link(label, action) should render link_to(label, url_for_mapping(:mapping, ...)), auto-detecting resource" do
    assert_equal link_to("Home!!", '/'),              link("Home!!", :home)
    assert_equal link_to("Home!!", '/', ONE_HASH),    link("Home!!", :home, ONE_HASH)
    assert_equal link_to("Home!!", '/', *TWO_HASHES), link("Home!!", :home, *TWO_HASHES)

    swap ::Link2, :action_mappings => {:secret => '/secret'} do
      assert_equal link_to("Damn you!!", '/secret'),              link("Damn you!!", :secret)
      assert_equal link_to("Damn you!!", '/secret', ONE_HASH),    link("Damn you!!", :secret, ONE_HASH)
      assert_equal link_to("Damn you!!", '/secret', *TWO_HASHES), link("Damn you!!", :secret, *TWO_HASHES)
    end
  end

  test "link(:action, Resource) should render link_to(t(:action, ...), url_for(:action => :action, ...))" do
    assert_equal link_to("New", "/fraggles/new"),               link(:new, ::Fraggle)
    assert_equal link_to("New", "/fraggles/new", ONE_HASH),     link(:new, ::Fraggle, ONE_HASH)
    assert_equal link_to("New", "/fraggles/new", *TWO_HASHES),  link(:new, ::Fraggle, *TWO_HASHES)
  end

  test "link(:action, @resource) should render link_to(t(:action, ...), url_for(:action => :action, ...)), non-RESTful vs. RESTful routes" do
    assert_equal link_to("New", "/fraggles/new?id=#{@mookey.id}"),              link(:new, @mookey)
    assert_equal link_to("New", "/fraggles/new?id=#{@mookey.id}", ONE_HASH),    link(:new, @mookey, ONE_HASH)
    assert_equal link_to("New", "/fraggles/new?id=#{@mookey.id}", *TWO_HASHES), link(:new, @mookey, *TWO_HASHES)

    assert_equal link_to("Edit", "/fraggles/#{@mookey.id}/edit"),               link(:edit, @mookey)
    assert_equal link_to("Edit", "/fraggles/#{@mookey.id}/edit", ONE_HASH),     link(:edit, @mookey, ONE_HASH)
    assert_equal link_to("Edit", "/fraggles/#{@mookey.id}/edit", *TWO_HASHES),  link(:edit, @mookey, *TWO_HASHES)
  end

  test "link(:action, [@parent, @resource]) should render link_to(t(:action, ...), polymorphic_path([@parent, @resource]), :action => :action)" do
    # assert_equal link_to("Edit", "/fraggles/#{@mookey.id}/cool_aids/#{@mookeys_cool_aid.id}/edit"), link(:edit, [@mookey, @mookeys_cool_aid])
    assert_raise(::Link2::NotImplementedYetError) { link(:edit, [@mookey, @mookeys_cool_aid]) }
    assert_raise(::Link2::NotImplementedYetError) { link(:edit, [@mookey, @mookeys_cool_aid], ONE_HASH) }
    assert_raise(::Link2::NotImplementedYetError) { link(:edit, [@mookey, @mookeys_cool_aid], *TWO_HASHES) }
  end

  test "auto-detecting resource: link(label, :action) should render link_to(label, @resource, :action => :action)" do
    self.expects(:current_controller_name).with(nil).returns('fraggles').at_least_once

    assert_raise(::Link2::Brain::AutoDetectionFailed) do
      link("Show it", :show)
    end

    @fraggle = @mookey

    assert_nothing_raised(::Link2::Brain::AutoDetectionFailed) do
      link("Show it", :show)
    end

    assert_equal link_to("Show it", "/fraggles/#{@fraggle.id}"),               link("Show it", :show)
    assert_equal link_to("Show it", "/fraggles/#{@fraggle.id}", ONE_HASH),     link("Show it", :show, ONE_HASH)
    assert_equal link_to("Show it", "/fraggles/#{@fraggle.id}", *TWO_HASHES),  link("Show it", :show, *TWO_HASHES)
  end

  test "auto-detecting collection: link(label, :action) should render link_to(label, @collection, :action => :action)" do
    self.expects(:current_controller_name).with(nil).returns('fraggles').at_least_once

    assert_raise(::Link2::Brain::AutoDetectionFailed) do
      link("All", :index)
    end

    @fraggles = [@mookey, @wembley]

    assert_nothing_raised(::Link2::Brain::AutoDetectionFailed) do
      link("All", :index)
    end

    assert_equal link_to("All", "/fraggles"),               link("All", :index)
    assert_equal link_to("All", "/fraggles", ONE_HASH),     link("All", :index, ONE_HASH)
    assert_equal link_to("All", "/fraggles", *TWO_HASHES),  link("All", :index, *TWO_HASHES)
  end

  # link(x, y,  z, {}, {})

  test "link(label, action, resource)" do
    assert_equal link_to("Newish", "/fraggles/new"),              link("Newish", :new, ::Fraggle)
    assert_equal link_to("Newish", "/fraggles/new", ONE_HASH),    link("Newish", :new, ::Fraggle, ONE_HASH)
    assert_equal link_to("Newish", "/fraggles/new", *TWO_HASHES), link("Newish", :new, ::Fraggle, *TWO_HASHES)

    assert_equal link_to("Editish", "/fraggles/#{@mookey.id}/edit"),              link("Editish", :edit, @mookey)
    assert_equal link_to("Editish", "/fraggles/#{@mookey.id}/edit", ONE_HASH),    link("Editish", :edit, @mookey, ONE_HASH)
    assert_equal link_to("Editish", "/fraggles/#{@mookey.id}/edit", *TWO_HASHES), link("Editish", :edit, @mookey, *TWO_HASHES)
  end

  test "js_link should not be implemented (yet)" do
    assert_raise(::Link2::NotImplementedYetError) { js_link(:alert, 'alert("New");', {}, {}) }
    assert_raise(::Link2::NotImplementedYetError) { js_button(:alert, 'alert("New");', {}, {}) }
  end

  test "ajax_link should not be implemented (yet)" do
    assert_raise(::Link2::NotImplementedYetError) { ajax_link(:home, {}, {}) }
    assert_raise(::Link2::NotImplementedYetError) { ajax_button(:home, {}, {}) }
  end

  # Nil

  test "should throw error on any nil argument (excluding options)" do
    self.stubs(:current_controller_name).returns('fraggles')
    @fraggle = @mookey

    assert_raise(::Link2::Brain::NilArgument) { link(nil) }

    assert_raise(::Link2::Brain::NilArgument) { link(Object.new, nil) }
    assert_raise(::Link2::Brain::NilArgument) { link(nil, Object.new) }

    assert_raise(::Link2::Brain::NilArgument) { link(nil, nil, nil) }
    assert_raise(::Link2::Brain::NilArgument) { link(Object.new, nil, nil) }
    assert_raise(::Link2::Brain::NilArgument) { link(nil, Object.new, nil) }
    assert_raise(::Link2::Brain::NilArgument) { link(nil, nil, Object.new) }
    assert_raise(::Link2::Brain::NilArgument) { link(Object.new, Object.new, nil) }
    assert_raise(::Link2::Brain::NilArgument) { link(Object.new, nil, Object.new) }
  end

  # DOM selectors

  test "link should generate DOM ID and class reflecting action and resource class - if any" do
    swap ::Link2, :dom_selectors => true do
      assert_equal link_to("New", "/fraggles/new", :class => 'new fraggle'),
        link(:new, ::Fraggle)

      assert_equal link_to("Edit", "/fraggles/#{@mookey.id}/edit", :class => "edit fraggle id_#{@mookey.id}"),
        link(:edit, @mookey)

      # TODO: Should pass when implemented.
      # assert_equal link_to("Edit fraggle", "/fraggles/#{@mookeys_cool_aid.id}/edit", :class => "edit cool_aid id_#{@mookeys_cool_aid.id}"),
      #         link(:edit, [@mookey, @mookeys_cool_aid])

      assert_equal link_to("Home", '/', :class => 'home'), link(:home)
      assert_equal link_to("Home", '/', :class => 'home'), link(:home, '/')
    end
  end

  # I18n

  test "link should lookup proper I18n labels" do
    swap ::Link2, :i18n_scopes => ['links.{{action}}'] do
      assert_match /\>Home\</, link(:home)
      assert_match /\>Back\</, link(:back)
      assert_match /\>New fraggle\</, link(:new, :fraggle)
      assert_match /\>New fraggle\</, link(:new, ::Fraggle)
      assert_match /\>New fraggle\</, link(:new, @mookey)
      assert_match /\>Edit fraggle\</, link(:edit, @mookey)
      # assert_match /\>Delete fraggle\</, link(:delete, @mookey)
      assert_match /\>Show fraggle\</, link(:show, @mookey)
      assert_match /\>Index of fraggles\</, link(:index, ::Fraggle)

      @mookey.class_eval do
        def to_s
          "off"
        end
      end
      assert_match /\>Show off\</, link(:show, @mookey)
    end
  end

end
