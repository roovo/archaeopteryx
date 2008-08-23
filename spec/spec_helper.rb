# this is my favorite way to require ever. <3
begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

begin
  require 'ruby-debug'
rescue LoadError
  require 'rubygems'
  gem 'ruby-debug'
  require 'ruby-debug'
end


module Spec::Example::ExampleGroupMethods
  def currently(name, &block)
    it("*** CURRENTLY *** #{name}", &block)
  end
end

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'archaeopteryx'

