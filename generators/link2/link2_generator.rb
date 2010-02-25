# encoding: utf-8

class Link2Generator < Rails::Generator::Base

  def manifest
    record do |m|
      m.template 'initializer.rb', File.join(*%w[config initializers link2.rb])
    end
  end

end