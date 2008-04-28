require File.join(File.dirname(__FILE__), 'constants_test_helper.rb') 
require 'constants_library'

class ConstantsLibraryTest < Test::Unit::TestCase
  
  class NameNumber
    attr_reader :name, :num
    def initialize(name,num)
      @name = name
      @num = num
    end
  end
  
  class TestLib < NameNumber
    include ConstantsLibrary
    
    A = TestLib.new('A', 1) unless defined?(A)
    B = TestLib.new('B', 2) unless defined?(B)
    C = TestLib.new('C', 3) unless defined?(C)
    
    library.reset
    library.add_lookup_by :name
    library.add_lookup :number do |item|
      [item.num, item]
    end
    
    library.add_collection_by :name
    library.add_collection :number do |item|
      [item, item.num]
    end
  end
  
  #
  # library test
  #
  
  def test_library
    assert_equal 3, TestLib.library.items.length
    TestLib.library.items.each do |item|
      assert_equal TestLib, item.class
      assert_equal TestLib.const_get(item.name), item
    end

    assert_equal [:name, :number], TestLib.library.lookup_names
    assert_equal({'A' => TestLib::A, 'B' => TestLib::B, 'C' => TestLib::C}, TestLib.library.lookups[:name])
    assert_equal({1 => TestLib::A, 2 => TestLib::B, 3 => TestLib::C}, TestLib.library.lookups[:number])
    assert_equal TestLib.library.lookups[:name]['A'], TestLib.lookup(:name, 'A')
    assert_raise(NoMethodError) { TestLib.lookup(:non_existant, nil) }
    
    assert_equal [:name, :number], TestLib.library.collection_names
    assert_equal(['A', 'B', 'C'].sort, TestLib.library.collections[:name].sort)
    assert_equal([nil, TestLib::A, TestLib::B, TestLib::C], TestLib.library.collections[:number])
    assert_equal TestLib.library.collections[:name], TestLib.collection(:name)
    assert_nil TestLib.collection(:non_existant)
    
    assert_equal TestLib::A, TestLib['A']
    assert_equal TestLib::A, TestLib[1]
    assert_nil TestLib[0]
  end

  #
  # [] tests
  #
  
  def test_REF
    assert_equal TestLib::A, TestLib['A']
    assert_equal TestLib::A, TestLib[1]
    assert_equal TestLib::A, TestLib[TestLib::A]
  end
  
  def test_REF_is_case_sensitive
    assert_nil TestLib['a']
  end
  
  #
  # test clear
  #
  
  class ClearLib < NameNumber
    include ConstantsLibrary
    
    A = ClearLib.new('A', 1) unless defined?(A)
    B = ClearLib.new('B', 2) unless defined?(B)
    C = ClearLib.new('C', 3) unless defined?(C)
    
    library.reset
    
    library.add_lookup :number do |item|
      [item.num, item]
    end
    
    library.add_collection :number do |item|
      [item, item.num]
    end
  end
  
  def test_clear
    # check the setup
    assert_equal 3, ClearLib.library.items.length
    assert_equal [:number], ClearLib.library.lookup_names
    assert_equal({1 => ClearLib::A, 2 => ClearLib::B, 3 => ClearLib::C}, ClearLib.library.lookups[:number])
    assert_equal [:number], ClearLib.library.collection_names
    assert_equal([nil, ClearLib::A, ClearLib::B, ClearLib::C], ClearLib.library.collections[:number])
    
    # check that clear clears items, lookups, and collections
    ClearLib.library.clear
    
    assert_equal 0, ClearLib.library.items.length
    assert_equal [:number], ClearLib.library.lookup_names
    assert_equal({}, ClearLib.library.lookups)
    assert_equal [:number], ClearLib.library.collection_names
    assert_equal({}, ClearLib.library.collections)
    
    # assure that the lookup and collection blocks are NOT 
    # cleared by showing that add adds lookups and collections
    d = ClearLib.new('D', 4)
    ClearLib.library.add d
    
    assert_equal 1, ClearLib.library.items.length
    assert_equal({4 => d}, ClearLib.library.lookups[:number])
    assert_equal([nil, nil, nil, nil, d], ClearLib.library.collections[:number])
    
    # check that clear complete clears blocks as well
    ClearLib.library.clear(true)
    
    assert_equal 0, ClearLib.library.items.length
    assert_equal [], ClearLib.library.lookup_names
    assert_equal({}, ClearLib.library.lookups)
    assert_equal [], ClearLib.library.collection_names
    assert_equal({}, ClearLib.library.collections)
    
    e = ClearLib.new('E', 5)
    ClearLib.library.add e
    
    assert_equal 1, ClearLib.library.items.length
    assert_equal [], ClearLib.library.lookup_names
    assert_equal({}, ClearLib.library.lookups)
    assert_equal [], ClearLib.library.collection_names
    assert_equal({}, ClearLib.library.collections)
  end
  
  #
  # reset test 
  #
  
  class AltLib < NameNumber
  end
  
  class ResetLib < NameNumber
    include ConstantsLibrary
    
    A = ResetLib.new('A', 1) unless defined?(A)
    B = AltLib.new('B', 2) unless defined?(B)
    C = ResetLib.new('C', 3) unless defined?(C)
    D = ResetLib.new('D', 4) unless defined?(D)
    
    library.add_lookup :number do |item|
      [item.num, item]
    end
  end
  
  def test_reset
    # test reset initializes with all constants of the base class
    assert_equal 0, ResetLib.library.items.length
    ResetLib.library.reset
    assert_equal 3, ResetLib.library.items.length
    assert_equal ['A', 'C', 'D'].sort, ResetLib.library.items.collect {|item| item.name}.sort
    ResetLib.library.items.each do |item|
      assert_equal ResetLib, item.class
      assert_equal ResetLib.const_get(item.name), item
    end
    
    # now test with block to select items
    ResetLib.library.reset do |item|
      item.respond_to?(:num) && item.num <= 2
    end
    assert_equal 2, ResetLib.library.items.length
    assert_equal ['A', 'B'].sort, ResetLib.library.items.collect {|item| item.name}.sort
  end
  
  #
  # add_collection and add_lookup tests
  #
  
  class AcAlLib < NameNumber
    include ConstantsLibrary
    
    A = AcAlLib.new('A', 1) unless defined?(A)
    B = AcAlLib.new('B', 2) unless defined?(B)
    C = AcAlLib.new('C', 3) unless defined?(C)

    # demonstrates:
    # * nil - ignore
    # * value specification
    # * [key, value] specification
    
    library.add_lookup :ab do |item|
      item.num <= 2 ? item.name : nil
    end
    
    library.add_lookup :name_num do |item|
      [item.name, item.num]
    end
    
    # demonstrates:
    # * nil - ignore
    # * value specification
    # * [value, index] specification
    
    library.add_collection :ab do |item|
      item.num <= 2 ? item.name : nil
    end
    
    library.add_collection :name_num do |item|
      [item.name, item.num]
    end
    
    library.reset
  end
  
  def test_add_collection_and_add_lookup
    assert_equal 3, AcAlLib.library.items.length
    assert_equal({'A' => AcAlLib::A, 'B' => AcAlLib::B}, AcAlLib.library.lookups[:ab])
    assert_equal({'A' => 1, 'B' => 2, 'C' => 3}, AcAlLib.library.lookups[:name_num])
    assert_equal ['A','B'].sort, AcAlLib.library.collections[:ab].sort
    assert_equal [nil, 'A', 'B', 'C'], AcAlLib.library.collections[:name_num]
    
    d = AcAlLib.new('D', 5)
    AcAlLib.library.add d
    
    assert_equal 4, AcAlLib.library.items.length
    assert_equal({'A' => AcAlLib::A, 'B' => AcAlLib::B}, AcAlLib.library.lookups[:ab])
    assert_equal({'A' => 1, 'B' => 2, 'C' => 3, 'D' => 5}, AcAlLib.library.lookups[:name_num])
    assert_equal ['A','B'].sort, AcAlLib.library.collections[:ab].sort
    assert_equal [nil, 'A', 'B', 'C', nil, 'D'], AcAlLib.library.collections[:name_num]    
  end
  
  #
  # add test
  #
  
  class AddLib < NameNumber
    include ConstantsLibrary
  
    library.add_lookup :name do |item|
      item.name
    end
    
    library.add_collection :name_num do |item|
      [item.name, item.num]
    end
  end
  
  def test_add_raises_error_for_lookup_and_collection_conflicts
    AddLib.library.add AddLib.new('A', 1)
    assert_raise(RuntimeError) { AddLib.library.add AddLib.new('A', 2) }
    assert_raise(RuntimeError) { AddLib.library.add AddLib.new('B', 1) }
  end
  
  
  #
  # merge! test
  #
  
  class AoOLib < NameNumber
    include ConstantsLibrary
    
    A = AoOLib.new('A', 1) unless defined?(A)
    B = AoOLib.new('B', 2) unless defined?(B)
    C = AoOLib.new('C', 3) unless defined?(C)

    library.add_lookup_by :name
    library.add_collection :number do |item, index|
      [item, item.num]
    end
    library.reset
  end
  
  def test_merge!
    assert_equal 3, AoOLib.library.items.length
    assert_equal({'A' => AoOLib::A, 'B' => AoOLib::B, 'C' => AoOLib::C}, AoOLib.library.lookups[:name])
    assert_equal [nil, AoOLib::A, AoOLib::B, AoOLib::C], AoOLib.library.collections[:number]
    
    bb = AoOLib.new('BB', 2)
    cc = AoOLib.new('CC', 8)
    d = AoOLib.new('D', 5)
    
    AoOLib.library.merge!('B' => bb, 'C' => cc, 'D' => d)
    assert_equal 4, AoOLib.library.items.length
    assert_equal({'A' => AoOLib::A, 'BB' => bb, 'CC' => cc, "D" => d}, AoOLib.library.lookups[:name])
    assert_equal [nil, AoOLib::A, bb, nil, nil, d, nil, nil, cc], AoOLib.library.collections[:number]
  end
  
  #
  # benchmark
  #
  
  def test_access_speed
    benchmark_test(24) do |x|
      n = 100
      x.report("#{n}k TestLib::A") do 
        (n*10**3).times { TestLib::A }
      end

      x.report("#{n}k TestLib['A']") do 
        (n*10**3).times { TestLib['A'] }
      end
      
      x.report("#{n}k lookup(:name,'A')") do 
        (n*10**3).times { TestLib.lookup(:name, 'A') }
      end
    end
  end
end