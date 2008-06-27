require File.join(File.dirname(__FILE__), '../constants_test_helper.rb') 
require 'constants/stash'

class StashTest < Test::Unit::TestCase
  include Constants
  
  class StashingHash < Hash
    include Constants::Stash

    def initialize(*args)
      super(*args)
      @nil_value = nil
    end
  end
  
  attr_reader :s
  
  def setup
    @s = StashingHash.new
  end
  
  #
  # documentation test
  #
  
  def test_documentation
    s = StashingHash.new
  
    s.stash('key', 'one')
    assert_equal 'one', s['key']
   
    s.stash('key', 'two')
    assert_equal ['one' , 'two'], s['key']
    assert_equal Constants::Stash::StashArray, s['key'].class
  
    ###
    s = StashingHash.new
    assert_nil s['key']
    assert_nil s.nil_value

    s.stash('key', 1)
    assert_equal 1, s['key']

    s.stash('key', 2)
    assert_equal [1, 2], s['key']
  
    ###
    assert_raise(ArgumentError) { s.stash('key', nil) }
  end
  
  #
  # initialization test
  #
  
  def test_initialization_sets_nil_value
    s = StashingHash.new
    assert_equal({}, s)
    assert_equal(nil, s.nil_value)
  end
  
  #
  # stash test
  #
  
  def test_stash_stores_new_values_at_key
    s.stash('key', 'one')
    assert_equal({'key' => 'one'}, s)
  end
  
  def test_stash_stores_addition_values_in_a_StashArray
    s.stash('key', 'one')
    s.stash('key', 'two')
    s.stash('key', 'three')
    
    assert_equal({'key' => ['one', 'two', 'three']}, s)
    assert_equal Constants::Stash::StashArray, s['key'].class
  end
  
  def test_stash_handles_array_values_properly
    s.stash('key', ['one'])
    assert_equal({'key' => ['one']}, s)
    
    s.stash('key', ['two'])
    assert_equal({'key' => [['one'], ['two']]}, s)
    
    s.stash('key', ['three'])
    assert_equal({'key' => [['one'], ['two'], ['three']]}, s)
  end
  
  def test_stash_raises_error_for_nil_value_and_StashArray_values
    assert_raise(ArgumentError) { s.stash('key', s.nil_value) }
    assert_raise(ArgumentError) { s.stash('key', Stash::StashArray.new) }
  end
  
  def test_stash_returns_self
    assert_equal s, s.stash('key', 'value')
  end
  
end