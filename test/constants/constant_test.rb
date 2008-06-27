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
 
end