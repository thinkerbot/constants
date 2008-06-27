require File.join(File.dirname(__FILE__), '../constants_test_helper.rb') 
require 'constants/library'

class Constants::LibraryTest < Test::Unit::TestCase
  include Constants
  
  #
  # documentation test
  #

  module Color
    include Constants::Library

    RED = 'red'
    GREEN = 'green'
    BLUE = 'blue'
    GREY = 'grey'

    library.index_by('name') {|c| c }
    reset_library
  end

  def test_documentation

    #####
    assert_equal({
      'red' => Color::RED,
      'blue' => Color::BLUE,
      'green' => Color::GREEN,
      'grey' => Color::GREY}, 
    Color.index('name'))

    assert_equal Color::RED, Color['red']

    ####

    Color.library.index_by_attribute 'length'
    assert_equal({
      3 => Color::RED,
      4 => [Color::BLUE, Color::GREY],
      5 => Color::GREEN},
    Color.index('length'))  

    assert_equal [Color::BLUE, Color::GREY], Color[4]

    ####

    Color.library.collect_by('rgb') {|c| ['green', 'red', 'blue'].include?(c) ? c : nil }
    assert_equal [Color::RED, Color::GREEN, Color::BLUE], Color.collection('rgb')

    Color.library.collect_by_attribute 'length'
    assert_equal [nil, nil, nil, Color::RED, [Color::BLUE, Color::GREY], Color::GREEN], Color.collection('length')

    ####
    Color.library.add('yellow')
    assert_equal({
      3 => Color::RED,
      4 => [Color::BLUE, Color::GREY],
      5 => Color::GREEN,
      6 => 'yellow'},
    Color.index('length'))  

    Color.module_eval %Q{
      ORANGE = 'orange'
      reset_library
    }
    
    assert_equal({
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