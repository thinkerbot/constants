module Constants
  
  # Stash provides methods to store values by a non-unique key.  The 
  # initial stored value is directly stored by the key, subsequent 
  # values are grouped into a StashArray.  
  #
  #   class StashingHash < Hash
  #     include Constants::Stash
  #
  #     def initialize(*args)
  #       super(*args)
  #       @nil_value = nil
  #     end
  #   end
  #
  #   s = StashingHash.new
  #
  #   s.stash('key', 'one')
  #   s['key']                # => 'one'
  #  
  #   s.stash('key', 'two')
  #   s['key']                # => ['one' , 'two']
  #   s['key'].class          # => Constants::Stash::StashArray
  #
  # The stash method requires some kind of flag to differentiate when a new
  # value should be stored and when the existing value and new value
  # should be converted into a StashArray.  If the existing value as 
  # determined by [] is equal to the nil_value, then the new value is 
  # stored through []=.
  #
  #  s = StashingHash.new
  #  s['key']                # => nil    
  #  s.nil_value             # => nil
  #
  #  s.stash('key', 1)
  #  s['key']                # => 1
  # 
  #  s.stash('key', 2)
  #  s['key']                # => [1, 2]
  #
  # In the first case, the existing value for 'key' is equals the nil_value,
  # so the new value is set.  In the second case, the existing value for 'key' 
  # does not equal the nil_value; stash takes this as a signal that a 
  # non-unique key was specified and collects the values into a StashArray.
  # As a consequence, neither the nil_value nor StashArrays may be stashed.
  #
  #   s.stash('key', nil)   # ! ArgumentError
  #
  module Stash
    
    # A subclass of Array with no new functionality, necessary
    # to differentiate between regular arrays and collections
    # in a Stash.
    class StashArray < Array
    end
    
    # The value considered to be nil in store (used to
    # signal when a new value can be stashed for a given
    # key; if store[key] == nil_value, then a new value
    # can be stashed).
    attr_accessor :nil_value
    
    # Assigns the value to key in store.  If the store already has a
    # non-nil_value at key (as determined by []), then the existing 
    # and new value will be concatenated into a StashArray.  All 
    # subsequent values are added to the StashArray.  stash uses
    # the []= method to set values.
    #
    # nil_value and StashArray values cannot be stashed; either raises 
    # an error.
    def stash(key, value)
      case value
      when nil_value
        raise ArgumentError.new("the nil_value for self cannot be stashed")
      when StashArray
        raise ArgumentError.new("StashArrays cannot be stashed")
      end
      
      current_value = self[key]
      
      case current_value
      when nil_value
        self[key] = value
      when StashArray
        current_value << value
      else
        self[key] = StashArray.new([current_value, value])
      end
      
      self
    end
  end
  
end
