require File.join(File.dirname(__FILE__), '../constants_test_helper.rb') 
require 'constants/constant'

class ConstantTest < Test::Unit::TestCase
  include Constants
  
  #
  # parse test
  #
  
  def test_parse_documentation
    assert_equal [1.0, 0.2], Constant.parse("1.0(2)").to_a
    assert_equal [1.0078250321, 1/2500000000], Constant.parse("1.007 825 032 1(4)").to_a
    assert_equal [6.62606896, nil], Constant.parse("6.626 068 96").to_a
  end
  
  def test_parse
    assert_equal [1.0, nil], Constant.parse("1.0").to_a
    assert_equal [1.0, 0], Constant.parse("1.0(0)").to_a
    assert_equal [1.0, 0.1], Constant.parse("1.0(1)").to_a
    assert_equal [100, 1], Constant.parse("100(1)").to_a
    assert_equal [100, 11], Constant.parse("100(11)").to_a
    assert_equal [1234.54789, 0.00011], Constant.parse("1234.54789(11)").to_a
    assert_equal [1234.54789, 0.00011], Constant.parse("1234.547 89 (11)").to_a
    assert_equal [1000, 100], Constant.parse("1.0(1)e3").to_a
    assert_equal [0.001, 0.0001], Constant.parse("1.0(1)e-3").to_a
  end
  
  #
  # == test
  #
  
  def test_equal_compares_Numerics_with_value
    c = Constant.new(1.23)
    assert c == 1.23
    assert c != 1.24
    
    assert_equal 1.23, c
    assert_not_equal 1.24, c
  end
  
  def test_equal_compares_non_Numerics_directly
    c1 = Constant.new(1.23)
    c2 = Constant.new(1.23)
    c3 = Constant.new(1.24)
    
    assert c1 == c2
    assert c1 != c3
  end
  
  #
  # <=> test
  #
  
  def test_compare_compares_on_value
    c1 = Constant.new(1.23)
    c2 = Constant.new(1.23)
    c3 = Constant.new(1.24)
    
    assert_equal 0, c1 <=> c2
    assert_equal(-1, c1 <=> c3)
    assert_equal 1, c3 <=> c1
  end
  
  #
  # to_a test
  #
  
  def test_to_a_returns_value_uncertainty_array
    c = Constant.new(1.23)
    assert_equal [1.23, nil], c.to_a
    
    c = Constant.new(1.23, nil, 0.03)
    assert_equal [1.23, 0.03], c.to_a
  end
 
end