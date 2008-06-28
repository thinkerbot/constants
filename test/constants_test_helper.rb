require 'rubygems'
require 'test/unit'
require 'benchmark'
require 'pp'

class Test::Unit::TestCase
  include Benchmark

  #
  # mass tests
  #
  
  def delta_mass
    10**-5
  end
  
  def delta_abundance
    10**-1
  end
  
  def benchmark_test(length=10, &block) 
    if ENV["benchmark"] =~ /true/i
      puts
      puts method_name
      bm(length, &block)
    else
      print 'b'
    end
  end
  
  def const_ordered_assert_equal(a,b, msg=nil)
    if RUBY_VERSION =~ /^1.8/
      print "*"
      
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
    else
      assert_equal a, b, msg
    end
  end
  
end
