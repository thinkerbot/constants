require 'constants/stash'

module Constants

  # The underlying class for Constants::Library.library.  See 
  # Constants::Library for more details.
  class ConstantLibrary
    
    # A hash-based stash to index library objects.
    class Index < Hash
      include Constants::Stash
      
      # The block used to calculate keys during stash
      attr_reader :block
      
      # Indicates when values are skipped during stash
      attr_reader :exclusion_value
      
      def initialize(exclusion_value, nil_value, &block)
        super(nil_value, &nil)
        @nil_value = nil_value
        @exclusion_value = exclusion_value
        @block = block
      end

      # Stashes the specified values in self using keys calculated 
      # by the block.  Values are skipped if the block returns the
      # exclusion value.  See Constants::ConstantLibrary#index_by for
      # more details.
      def stash(values)
        values.each_with_index do |value, index| 
          result = block.call(value)
          
          case result
          when exclusion_value then next
          when Array then super(*result)
          else super(result, value)
          end
        end
        
        self
      end
    end
    
    # An array-based stash for collections of library objects.
    class Collection < Array
      include Constants::Stash
      
      # The block used to calculate keys during stash
      attr_reader :block
      
      # Indicates when values are skipped during stash
      attr_reader :exclusion_value
      
      def initialize(exclusion_value, nil_value, &block)
        super(0, nil_value, &nil)
        @nil_value = nil_value
        @exclusion_value = exclusion_value
        @block = block
      end
      
      # Stashes the specified values in self at indicies calculated 
      # by the block.  Values are skipped if the block returns the
      # exclusion value.  See Constants::ConstantLibrary#collect_by for
      # more details.
      def stash(values)
        values.each do |value| 
          value, index = block.call(value)
          index = self.length if index == nil
          
          case value
          when exclusion_value then next
          else super(index, value)
          end
        end
        
        self
      end
    end
    
    # An array of values in the library
    attr_reader :values
    
    # A hash of name, index pairs tracking the indicies in self
    attr_reader :indicies
    
    # A hash of name, collection pairs tracking the collections in self
    attr_reader :collections

    def initialize(*values)
      @values = values.uniq
      @indicies = {}
      @collections = {}
    end
    
    # Adds an index to self for all values currently in self.  The block is 
    # used to specify keys for each value in self; it receives each value and 
    # should return one of the following: 
    # - a key
    # - a [key, value] array when an alternate value should be stored
    #   in the place of value
    # - the exclusion_value to exclude the value from the index
    #
    # Existing indicies by the specified name are overwritten.
    #
    # === nil values
    #
    # The index stores it's data in a hash, which will return nil_value for
    # non-existant keys.  Note that index_by will raise an error if you try
    # to store the nil_value; in short, nils are usually not allowed.  For
    # example (noting that an unusual exclusion value is set so that the
    # nil values actually are stored rather than simply being excluded):
    #
    #   lib = Library.new(1,2,nil)                       # the nil will cause trouble
    #   lib.index_by "error", 10, nil {|value| value }   # ! ArgumentError
    #
    # Simply specify an alternate nil_value to index nils; oftentimes an
    # annonymous Object works well.  However, note that in all cases the
    # underlying index data store will return this nil value for non-existant
    # keys.
    #
    #   obj = Object.new
    #   index = lib.index_by("ok", 10, obj) {|value| value }
    #   index[1]                 # => 1
    #   index[nil]               # => nil
    #   index['non-existant']    # => obj
    # 
    def index_by(name, exclusion_value=nil, nil_value=nil, &block) # :yields: value
      raise ArgumentError.new("no block given") unless block_given?
      
      index = Index.new(exclusion_value, nil_value, &block)
      indicies[name] = index
      index.stash(values)
    end
    
    # Adds an index for the specified attribute or method (evaluated
    # on each value, of course).
    def index_by_attribute(attribute, exclusion_value=nil, nil_value=nil)
      index_by(attribute.to_s, exclusion_value, nil_value) {|value| value.send(attribute) }
    end
    
    # Adds a collection to self for all values currently in self.  Works much
    # like index_by, except that the underlying data store for a collection 
    # is an array, and the returns of the block are handled accordingly. The 
    # block receives each value and should return one of the following: 
    # - a value
    # - a [value, index] array when an alternate value should be stored
    #   in the place of value, or when the value should be at a special
    #   index in the collection
    # - the exclusion_value to exclude the value from the collection
    #
    # See index_by for additional details regarding exclusion_value and nil_value.
    def collect_by(name, exclusion_value=nil, nil_value=nil, &block) # :yields: value
      raise ArgumentError.new("no block given") unless block_given?
      
      collection = Collection.new(exclusion_value, nil_value, &block)
      collections[name] = collection
      collection.stash(values)
    end
    
    # Adds a collection for the specified attribute or method (evaluated
    # on each value, of course).
    def collect_by_attribute(attribute, exclusion_value=nil, nil_value=nil)
      collect_by(attribute.to_s, exclusion_value, nil_value) {|value| value.send(attribute) }
    end
    
    # Lookup values by a key.  All indicies will be searched in order; the first 
    # matching value is returned.  If no matches are found, values is searched 
    # for an value that equals the key.  If found, the matching value is returned,
    # otherwise the return will be nil. 
    def [](key)
      indicies.values.each do |index|
        return index[key] if index.has_key?(key)
      end
    
      values.include?(key) ? key : nil
    end
    
    # Clears all values, from self, indicies, and collections.  The indicies, 
    # and collections themselves are preserved unless complete==true.
    def clear(complete=false)
      values.clear
      
      [indicies, collections].each do |stashes|
        complete ? stashes.clear : stashes.values.each {|stash| stash.clear}
      end
    end
    
    # Add the specified values to self.  New values are incorporated into existing
    # indicies and collections.  Returns the values added (ie values minus any 
    # already-existing values). 
    def add(*values)
      new_values = values - self.values
      self.values.concat(new_values)
    
      [indicies, collections].each do |stashes|
        stashes.values.each do |stash| 
          stash.stash(new_values)
        end
      end

      #new_values.each(&add_block) if add_block
      new_values
    end
    
    def add_from(mod)
      const_names = mod.constants.select do |const_name|
        const = mod.const_get(const_name)
        block_given? ? yield(const) : const.kind_of?(mod)
      end
      add(*const_names.collect {|const_name| mod.const_get(const_name) })
    end
    
    # # Specifies a block to execute when values are added to self.  
    # # Existing values are sent to the add_block immediately.
    # def on_add(override=false, &block) # :yields: value
    #   raise "Add block already set!" unless add_block.nil? || override
    #   @add_block = block
    #   values.each(&block)
    #   block
    # end

    # def merge!(hash)
    #   hash.each_pair do |key, item|
    #     existing = self[key]
    #     if existing != nil
    #       items[items.index(existing)] = item
    #     else
    #       add(item)
    #     end
    #   end
    # 
    #   items = self.items
    #   self.clear(false)
    #   add *items
    # end

  end
end