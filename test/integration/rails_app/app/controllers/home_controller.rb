# encoding: utf-8

class HomeController < ApplicationController

  def index
    @blue_pony = Pony.create
    @pink_pony = Pony.create
    @blue_pony.ponies << @pink_pony
  end

end