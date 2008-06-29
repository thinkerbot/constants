require File.join(File.dirname(__FILE__), '../constants_test_helper.rb') 
require 'constants/constant_library'

class ConstantLibraryTest < Test::Unit::TestCase
  include Constants

  attr_accessor :lib
  
  def setup
    @lib = ConstantLibrary.new 'one', 'two', :one
  end
  
  #
  # documentation test
  #
  
  def test_documentation
    lib = ConstantLibrary.new('one', 'two', :three)
    lib.index_by('upcase') {|value| value.to_s.upcase }
    assert_equal({'ONE' => 'one', 'TWO' => 'two', 'THREE' => :three}, lib.indicies['upcase'])
  
    lib.collect("string") {|value| value.to_s }
    assert_equal(['one', 'two', 'three'], lib.collections['string'])
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
  
  def test_index_by_documentation
    lib = ConstantLibrary.new('one', 'two', :one)
    lib.index_by("string") {|value| value.to_s }
    assert_equal({
      'one' => ['one', :one],
      'two' => 'two'},
    lib.indicies['string'])

    lib = ConstantLibrary.new(1,2,nil)                          
    assert_raise(ArgumentError) { lib.index_by("error", false, nil) {|value| value } }


    obj = Object.new
    index = lib.index_by("ok", false, obj) {|value| value }
    assert_equal 1, index[1]
    assert_equal nil, index[nil]

    assert_equal obj, index['non-existant']
  end

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
  
  def test_index_by_uses_name_as_indicies_key
    lib.index_by(:sym) {|v| v.to_s }
    assert lib.indicies.has_key?(:sym)
    assert !lib.indicies.has_key?('sym')
    
    lib.index_by('str') {|v| v.to_s }
    assert !lib.indicies.has_key?(:str)
    assert lib.indicies.has_key?('str')
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
  # collect test
  #
  
  def test_collect_documentation
    lib = ConstantLibrary.new('one', 'two', :three)
    lib.collect("string") {|value| value.to_s }
    assert_equal ['one', 'two', 'three'], lib.collections['string'] 
  
    lib.collect("length") {|value| [value, value.to_s.length] }
    assert_equal [nil, nil, nil, ['one', 'two'], nil, :three], lib.collections['length']
  end
  
  def test_collect_creates_a_new_collection_for_the_specified_inputs
    block = lambda {|v| }
    lib.collect("name", &block)
    
    assert lib.collections.has_key?('name')
    collection = lib.collections['name']
    
    assert_equal ConstantLibrary::Collection, collection.class
    assert_equal nil, collection.nil_value
    assert_equal block, collection.block
  end

  def test_collect_uses_name_as_collections_key
    lib.collect(:sym) {|v| v.to_s }
    assert lib.collections.has_key?(:sym)
    assert !lib.collections.has_key?('sym')
    
    lib.collect('str') {|v| v.to_s }
    assert !lib.collections.has_key?(:str)
    assert lib.collections.has_key?('str')
  end
  
  def test_collection_stashes_block_value
    lib.collect("string") {|v| v.to_s }
    assert_equal(['one', 'two', 'one'], lib.collections["string"])
  end

  def test_collection_stashes_values_index_pairs_if_returned
    map = {'one' => 2, 'two' => 0}

    lib.collect("pairs") {|v| [v, map[v.to_s]] }
    assert_equal(['two', nil, ['one', :one]], lib.collections["pairs"])
  end

  def test_collection_excludes_values_which_return_nil
    lib.collect("exclusion") do |v| 
      v.kind_of?(String) ? nil : v
    end
    assert_equal([:one], lib.collections["exclusion"])
  end

  def test_collect_raises_error_for_no_block_given
    assert_raise(ArgumentError) { lib.collect('name') }
  end

  def test_collect_returns_collection
    result = lib.collect("name") {|v|}
    assert_equal(lib.collections['name'], result)
  end
  
  # 
  # collect_attribute test
  #
  
  def test_collect_attribute_collects_attribute_values
    lib.collect_attribute("to_s")
    assert_equal(['one', 'two', 'one'], lib.collections["to_s"])
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
    lib.collect("str") {|v| v.to_s }
    
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
    lib.collect("str") {|v| v.to_s }
    
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
    lib.collect("length") {|v| [v, v.to_s.length] }
    
    lib.add(:one, :two, 'two', 'three')
    assert_equal({'one' => ['one', :one], 'two' => ['two', :two], 'three' => 'three'}, lib.indicies['str'])
    assert_equal([nil,nil,nil,['one', 'two', :one, :two], nil, 'three'], lib.collections['length'])
  end
  
end
