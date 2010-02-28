# encoding: utf-8

ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'home'

  map.resources :ponies, :member => {:shut_up => :get} do |ponies|
    ponies.resources :ponies
  end

  # WHY?: Tests fails when these are enabled.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'

end