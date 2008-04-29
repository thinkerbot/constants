require File.join(File.dirname(__FILE__), '../../constants_test_helper.rb') 
require 'constants/library/physical'

class PhysicalTest < Test::Unit::TestCase
  include Constants::Library
  
  #
  # initialize test
  #
  
  def test_initialize
    c = Physical::SPEED_OF_LIGHT_IN_VACUUM
    
    assert_equal "speed of light in vacuum", c.name
    assert_equal 299792458, c.value
    assert_equal 0, c.uncertainty
    assert_equal Unit.new("m/s"), c.unit
  end
  
  #
  # lookup test
  #
  
  def test_lookup
    c = Physical::SPEED_OF_LIGHT_IN_VACUUM
    assert_equal c, Physical["speed of light in vacuum"]
  end
  
  def test_lookup_is_nil_for_undefined_constants
    assert_nil Physical["made up blah in a blah"]
  end
end