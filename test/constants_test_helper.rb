require 'rubygems'
require 'tap/test'
require 'tap/test/subset_test_class'
require 'pp'

class Test::Unit::TestCase
  acts_as_subset_test
  
  condition(:ruby_1_8) { RUBY_VERSION =~ /^1.8/ }
  condition(:ruby_1_9) { RUBY_VERSION =~ /^1.9/ }
  
  #
  # mass tests
  #

  def delta_mass
    10**-5
  end

  def delta_abundance
    10**-1
  end

  def const_ordered_assert_equal(a,b, msg=nil)
    condition_test(:ruby_1_8) do
      case a
      when Array
        assert_equal a.sort, b.sort, msg
      when Hash
        [a,b].each do |hash|
          hash.each_pair do |key, value|
            value.sort! if value.kind_of?(Array)
          end
        end
        assert_equal a, b, msg
      end    
    end
    
    condition_test(:ruby_1_9) do
      assert_equal a, b, msg
    end
  end
end unless Test::Unit::TestCase.kind_of?(Tap::Test::SubsetTestClass)
