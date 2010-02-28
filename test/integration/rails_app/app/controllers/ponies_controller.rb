# encoding: utf-8

class PoniesController < ApplicationController

  def index
  end

  def shut_up
    render :text => "Shut up Blue Pony; you are not as blue as you think!"
  end

end
