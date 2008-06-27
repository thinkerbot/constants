require File.join(File.dirname(__FILE__), '../constants_test_helper.rb') 
require 'constants/constant_library'

class ConstantLibraryTest < Test::Unit::TestCase
  include Constants

  attr_accessor :lib
  
  def setup
    @lib = ConstantLibrary.new 'one', 'two', :one
  end
  
  #
  # initialize test
  #
  
  def test_initialize
    lib = ConstantLibrary.new 
    
    assert_equal([], lib.values)
    assert_equal({}, lib.indicies)
    assert_equal({}, lib.collections)
  end
  
  def test_initialize_with_values
    assert_equal(['one', 'two', :one], lib.values)
  end
  
  def test_initialize_removes_duplicate_values
    lib = ConstantLibrary.new 'one', 'two', 'one'
    assert_equal(['one', 'two'], lib.values)
  end

  # 
  # index_by test
  #
  
  def test_index_by_creates_a_new_index_for_the_specified_inputs
    block = lambda {|v| }
    lib.index_by("name", "nil", "nil_value", &block)
    
    assert lib.indicies.has_key?('name')
    index = lib.indicies['name']
    
    assert_equal ConstantLibrary::Index, index.class
    assert_equal "nil", index.exclusion_value
    assert_equal "nil_value", index.nil_value
    assert_equal block, index.block
  end
  
  def test_index_stashes_values_by_block
    lib.index_by("string") {|v| v.to_s }
    assert_equal({'one' => ['one', :one], 'two' => 'two'}, lib.indicies["string"])
  end
  
  def test_index_stashes_key_value_pairs_if_returned
    lib.index_by("pairs") {|v| [v, v.to_s.upcase] }
    assert_equal({'one' => 'ONE', :one => 'ONE', 'two' => 'TWO'}, lib.indicies["pairs"])
  end
  
  def test_index_excludes_values_which_return_the_exclusion_value
    lib.index_by("exclusion", nil) do |v| 
      v.kind_of?(String) ? nil : [v, v.to_s.upcase]
    end
    
    assert_equal({:one => 'ONE'}, lib.indicies["exclusion"])
  end
  
  def test_index_by_default_exclusion_value_is_nil
    lib.index_by("name") {|v|}
    assert_equal nil, lib.indicies['name'].exclusion_value
  end
  
  def test_index_by_raises_error_for_no_block_given
    assert_raise(ArgumentError) { lib.index_by('name') }
  end
  
  def test_index_by_returns_index
    result = lib.index_by("name") {|v|}
    assert_equal(lib.indicies['name'], result)
  end
  
  # 
  # index_by_attribute test
  #
  
  def test_index_by_attribute_stashes_values_by_method_value
    lib.index_by_attribute("to_s")
    assert_equal({'one' => ['one', :one], 'two' => 'two'}, lib.indicies["to_s"])
  end
  
  def test_index_by_attribute_returns_index
    result = lib.index_by_attribute("object_id")
    assert_equal(lib.indicies['object_id'], result)
  end
  
  def test_index_by_attribute_raises_error_if_objects_dont_respond_to_attribute
    assert_raise(NoMethodError) { lib.index_by_attribute("non_existant") }
  end
  
  # 
  # collect_by test
  #
  
  def test_collect_by_creates_a_new_collection_for_the_specified_inputs
    block = lambda {|v| }
    lib.collect_by("name", "nil", "nil_value", &block)
    
    assert lib.collections.has_key?('name')
    collection = lib.collections['name']
    
    assert_equal ConstantLibrary::Collection, collection.class
    assert_equal "nil", collection.exclusion_value
    assert_equal "nil_value", collection.nil_value
    assert_equal block, collection.block
  end

  def test_collection_stashes_block_value
    lib.collect_by("string") {|v| v.to_s }
    assert_equal(['one', 'two', 'one'], lib.collections["string"])
  end

  def test_collection_stashes_values_index_pairs_if_returned
    map = {'one' => 2, 'two' => 0}

    lib.collect_by("pairs") {|v| [v, map[v.to_s]] }
    assert_equal(['two', nil, ['one', :one]], lib.collections["pairs"])
  end

  def test_collection_excludes_values_which_return_the_exclusion_value
    lib.collect_by("exclusion", nil) do |v| 
      v.kind_of?(String) ? nil : v
    end
    assert_equal([:one], lib.collections["exclusion"])
  end

  def test_collect_by_raises_error_for_no_block_given
    assert_raise(ArgumentError) { lib.collect_by('name') }
  end

  def test_collect_by_returns_collection
    result = lib.collect_by("name") {|v|}
    assert_equal(lib.collections['name'], result)
  end

  #
  # [] test
  #
 
  def test_get_searches_all_indicies_match
    lib.index_by("string") {|v| v.to_s }
    lib.index_by("strlen") {|v| v.to_s.length }
    
    assert_equal ['one', :one], lib['one']
    assert_equal ['one', 'two', :one], lib[3]
  end
  
  def test_get_searches_items_for_match_if_no_indicies_match
    assert lib.indicies.empty?
    assert_equal 'one', lib['one']
  end
  
  def test_get_returns_nil_if_no_matches_are_found
    assert_equal nil, lib['three']
  end
  
  def test_get_returns_first_match_only
    lib.index_by("str1") {|v| v.to_s }
    lib.index_by("str2") {|v| [v.to_s, v.to_s.upcase] }
    
    assert lib.indicies['str1'].has_key?('one')
    assert lib.indicies['str2'].has_key?('one')
    
    assert_not_equal lib.indicies['str1']['one'], lib.indicies['str2']['one']
    assert_equal lib.indicies['str1']['one'], lib['one']
  end
  
  #
  # clear test
  #
  
  def test_clear_clears_all_values_from_lib_indicies_and_collections
    lib.index_by("str") {|v| v.to_s }
    lib.collect_by("str") {|v| v.to_s }
    
    assert !lib.values.empty?
    assert !lib.indicies['str'].empty?
    assert !lib.collections['str'].empty?
    
    lib.clear
    
    assert lib.values.empty?
    assert lib.indicies['str'].empty?
    assert lib.collections['str'].empty?
  end
  
  def test_clear_only_removes_indicies_and_collections_if_specified
    lib.index_by("str") {|v| v.to_s }
    lib.collect_by("str") {|v| v.to_s }
    
    lib.clear
    
    assert !lib.indicies.empty?
    assert !lib.collections.empty?
    
    lib.clear(true)
    
    assert lib.indicies.empty?
    assert lib.collections.empty?
  end
  
  #
  # add test
  #
  
  def test_add_adds_new_values
    lib.add(:two, 'three')
    assert_equal ['one', 'two', :one, :two, 'three'], lib.values
  end
  
  def test_add_does_not_add_duplicate_values
    lib.add(:one, :two, 'two', 'three')
    assert_equal ['one', 'two', :one, :two, 'three'], lib.values
  end
  
  def test_add_returns_newly_added_values
    assert_equal [:two, 'three'], lib.add(:one, :two, 'two', 'three')
  end
  
  def test_add_incorporates_new_values_into_existing_indicies_and_collections
    lib.index_by("str") {|v| v.to_s }
    lib.collect_by("length") {|v| [v, v.to_s.length] }
    
    lib.add(:one, :two, 'two', 'three')
    assert_equal({'one' => ['one', :one], 'two' => ['two', :two], 'three' => 'three'}, lib.indicies['str'])
    assert_equal([nil,nil,nil,['one', 'two', :one, :two], nil, 'three'], lib.collections['length'])
  end
  
end
