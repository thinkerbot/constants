require File.join(File.dirname(__FILE__), '../constants_test_helper.rb') 
require 'constants/library'

class Constants::LibraryTest < Test::Unit::TestCase
  include Constants
  
  #
  # documentation test
  #

  module Color
    RED = 'red'
    GREEN = 'green'
    BLUE = 'blue'
    GREY = 'grey'

    include Constants::Library
    library.index_by('name') {|c| c }
  end

  def test_documentation 
    ###
    assert_equal({
      'red' => Color::RED,
      'blue' => Color::BLUE,
      'green' => Color::GREEN,
      'grey' => Color::GREY},
    Color.index('name'))

    assert_equal Color::RED, Color['red']

    ###
    Color.library.index_by_attribute 'length'
    const_ordered_assert_equal({
      3 => Color::RED,
      4 => [Color::BLUE, Color::GREY],
      5 => Color::GREEN},
    Color.index('length'))

    const_ordered_assert_equal [Color::BLUE, Color::GREY], Color[4]
    
    ###
    Color.library.collect('gstar') {|c| c =~ /^g/ ? c : nil }
    const_ordered_assert_equal [Color::GREEN, Color::GREY], Color.collection('gstar')

    Color.library.collect_attribute 'length'
    const_ordered_assert_equal [3,5,4,4], Color.collection('length')

    ###
    Color.library.add('yellow')
    const_ordered_assert_equal({
      3 => Color::RED,
      4 => [Color::BLUE, Color::GREY],
      5 => Color::GREEN,
      6 => 'yellow'},
    Color.index('length'))

    Color.module_eval %Q{
      ORANGE = 'orange'
      reset_library
    }

    const_ordered_assert_equal({
      3 => Color::RED,
      4 => [Color::BLUE, Color::GREY],
      5 => Color::GREEN,
      6 => Color::ORANGE},
    Color.index('length'))
  end

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
    A = 'A'
    
    library.index_by("name") {|value| value}
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