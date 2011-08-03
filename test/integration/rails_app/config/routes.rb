# encoding: utf-8

ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'home'

  map.resources :ponies, :member => {:shut_up => :get} do |ponies|
    ponies.resources :ponies
  end

end