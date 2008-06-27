require File.join(File.dirname(__FILE__), '../constants_test_helper.rb') 
require 'constants/library'

class Constants::LibraryTest < Test::Unit::TestCase
  include Constants
  
  #
  # extend test 
  #
  
  module ExtendModule
  end
  
  def test_extend_initializes_library
    ExtendModule.extend Library
    assert ExtendModule.respond_to?(:library)
    assert ExtendModule.library.kind_of?(ConstantLibrary)
  end
  
  #
  # include test 
  #
  
  module IncludeModule
    include Constants::Library
  end
  
  def test_include_initializes_library
    assert IncludeModule.respond_to?(:library)
    assert IncludeModule.library.kind_of?(ConstantLibrary)
  end
  
  #
  # benchmark tests
  #
  
  module BenchmarkModule
    include Constants::Library
    A = 1
    
    library.index_by_attribute :name
    reset_library
  end

  def test_access_speed
    benchmark_test(24) do |x|
      n = 100
      x.report("#{n}k BenchmarkModule::A") do 
        (n*10**3).times { BenchmarkModule::A }
      end
  
      x.report("#{n}k ['A']") do 
        (n*10**3).times { BenchmarkModule['A'] }
      end
      
      x.report("#{n}k index('name')['A']") do 
        (n*10**3).times { BenchmarkModule.index('name')['A'] }
      end
    end
  end
end