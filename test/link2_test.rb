# encoding: utf-8

class Link2Test < ActiveSupport::TestCase

  test "#setup: setup block yields self" do
    Link2.setup do |config|
      assert_equal Link2, config
    end
  end

  test "#setup: should be configurable using setup helper" do
    swap Link2, :i18n_scopes => ['links.{{action}}'] do
      assert_equal ['links.{{action}}'], Link2.i18n_scopes
    end

    swap Link2, :action_mappings => {:home => '/'} do
      assert_equal ({:home => '/'}), Link2.action_mappings
    end

    swap Link2, :dom_selectors => true do
      assert_equal true, Link2.dom_selectors
    end
  end

  test "#url_for_mapping: should only map mapped action keys" do
    swap Link2, :action_mappings => {:home_sweet_home => '/welcome'} do
      assert_equal '/welcome', Link2.url_for_mapping(:home_sweet_home)
      assert_nil Link2.url_for_mapping(:unicorns_and_rainbows)
    end
  end

  test "#url_for_mapping: should be able to map procs" do
    swap Link2, :action_mappings => {:home_sweet_home => lambda { '/welcome' }} do
      assert_equal '/welcome', Link2.url_for_mapping(:home_sweet_home)
    end
  end

  test "#url_for_mapping: should be able to map procs with custom url" do
    swap Link2, :action_mappings => {:home_sweet_home => lambda { |url| url || '/welcome' }} do
      #assert_equal '/get_lost', Link2.url_for_mapping(:home_sweet_home, '/get_lost')
    end
  end

  # FAILS - see TODO:
  # test "#url_for_mapping: should be able to map procs containing named route (or helper method)" do
  #   swap Link2, :action_mappings => {:root => lambda { root_path }} do
  #     assert_equal root_path, Link2.url_for_mapping(:root)
  #   end
  # end

end
