require "rr"
require "date"
require "pry"
require "minitest/autorun"
require "active_record"

class MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest
end

ActiveRecord::Base.establish_connection :adapter => "sqlite3",
  :database => ":test:"

ENV["RAILS_ENV"] = "test"

def stub_module full_name
  full_name.to_s.split(/::/).inject(Object) do |context, name|
    begin
      context.const_get name
    rescue NameError
      context.const_set name, Module.new
    end
  end
end

def stub_class full_name
  full_name.to_s.split(/::/).inject(Object) do |context, name|
    begin
      context.const_get name
    rescue NameError
      klass = Class.new do
        def initialize *args
        end
      end
      context.const_set name, klass
    end
  end
end
