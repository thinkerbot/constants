require 'constants/stash'

module Constants

  # ConstantLibrary facilitates indexing and collection of a set of values.
  #
  #   lib = ConstantLibrary.new('one', 'two', :three)
  #   lib.index_by('upcase') {|value| value.to_s.upcase }
  #   lib.indicies['upcase']      # => {'ONE' => 'one', 'TWO' => 'two', 'THREE' => :three}
  #
  #   lib.collect("string") {|value| value.to_s }
  #   lib.collections['string']   # => ['one', 'two', 'three']
  #
  # See Constants::Library for more details.
  class ConstantLibrary
    
    # A hash-based Stash to index library objects.
    class Index < Hash
      include Constants::Stash
      
      # The block used to calculate keys during stash
      attr_reader :block
      
      # Indicates when values are skipped during stash
      attr_reader :exclusion_value
      
      # Initializes a new Index (a type of Hash).  
      #
      # The block is used by stash to calculate the key for 
      # stashing a given value.  If the key equals the exclusion 
      # value, then the value is skipped.  The new index will
      # return nil_value for unknown keys (ie it is the default
      # value for self) and CANNOT be stashed (see Stash). 
      def initialize(exclusion_value=nil, nil_value=nil, &block)
        super(nil_value, &nil)
        @nil_value = nil_value
        @exclusion_value = exclusion_value
        @block = block
      end

      # Stashes the specified values using keys calculated 
      # by the block.  Skips values when the block returns 
      # the exclusion value.  
      #
      # See Constants::ConstantLibrary#index_by for more details.
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
    
    # An array-based Stash for collections of library objects.
    #
    #-- 
    # Note: comparison of Index and Collection indicates that
    # these are highly related classes.  Why no exclusion value
    # and why no modifiable nil_value for Collection?  Simply
    # because an array ALWAYS returns nil for uninitialized
    # locations (esp out-of-bounds locations).  This means that
    # Stash, which uses the value at self[] to determine when
    # to stash and when not to stash, must have nil as it's
    # nil_value to behave correctly.  Effectively treating
    # nil as an exclusion value for collection works well in
    # this case since nils cannot be stashed.
    #
    # Hashes (ie Index) do not share this behavior.  Since you
    # can define a default value for missing keys, self[] can
    # return something other than nil... hence there is an 
    # opportunity to use non-nil nil_values and non-nil 
    # exclusion values.
    class Collection < Array
      include Constants::Stash
      
      # The block used to calculate keys during stash
      attr_reader :block

      # Initializes a new Collection (a type of Array).  The block is 
      # used by stash to calculate the values in a collection. 
      def initialize(&block)
        super()
        @nil_value = nil
        @block = block
      end
      
      # Stashes the specified values in self using values calculated 
      # by the block.  Values are skipped if the block returns nil.  
      #
      # See Constants::ConstantLibrary#collect for more details.
      def stash(values)
        values.each do |value| 
          value, index = block.call(value)
          next if value == nil
        
          super(index == nil ? self.length : index, value)
        end
        
        self
      end
    end
    
    # An array of values in the library
    attr_reader :values
    
    # A hash of (name, index) pairs tracking the indicies in self
    attr_reader :indicies
    
    # A hash of (name, collection) pairs tracking the collections in self
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
    # When multiple values return the same key, they are stashed into an array.
    #
    #   lib = ConstantLibrary.new('one', 'two', :one)
    #   lib.index_by("string") {|value| value.to_s }
    #   lib.indicies['string'] 
    #   # => {
    #   # 'one' => ['one', :one],
    #   # 'two' => 'two'} 
    #  
    # Existing indicies by the specified name are overwritten.
    #
    # ==== nil values
    #
    # The index stores it's data in an Index (ie a Hash) where nil_value
    # acts as the default value returned for non-existant keys as well as
    # the stash nil_value.  Hence index_by will raise an error if you try 
    # to store the nil_value.  
    # 
    # This behavior can be seen when the exclusion value is set to something
    # other than nil, so that the nil value isn't skipped outright:
    #
    #   # the nil will cause trouble
    #   lib = ConstantLibrary.new(1,2,nil)
    #   lib.index_by("error", false, nil) {|value| value }  # ! ArgumentError
    #
    # Specify an alternate nil_value (and exclusion value) to index nils; 
    # a plain old Object works well. 
    #
    #   obj = Object.new
    #   index = lib.index_by("ok", false, obj) {|value| value }
    #   index[1]                 # => 1
    #   index[nil]               # => nil
    #
    #   # remember the nil_value is the default value
    #   index['non-existant']    # => obj
    # 
    def index_by(name, exclusion_value=nil, nil_value=nil, &block) # :yields: value
      raise ArgumentError.new("no block given") unless block_given?
      
      index = Index.new(exclusion_value, nil_value, &block)
      indicies[name] = index
      index.stash(values)
    end
    
    # Adds an index using the attribute or method.  Equivalent to:
    #
    #   lib.index_by(attribute) {|value| value.attribute }
    #
    def index_by_attribute(attribute, exclusion_value=nil, nil_value=nil)
      method = attribute.to_sym
      index_by(attribute, exclusion_value, nil_value) {|value| value.send(method) }
    end
    
    # Adds a collection to self for all values currently in self.  The block
    # is used to calculate the values in the collection.  The block receives 
    # each value in self and should return one of the following: 
    # - a value to be pushed onto the collection
    # - a [value, index] array when an alternate value should be stored
    #   in the place of value, or when the value should be at a special
    #   index in the collection. When multiple values are directed to the 
    #   same index, they are stashed into an array.
    # - nil to exclude the value from the collection
    #
    # For example:
    #
    #   lib = ConstantLibrary.new('one', 'two', :three)
    #   lib.collect("string") {|value| value.to_s }
    #   lib.collections['string']   # => ['one', 'two', 'three']
    #
    #   lib.collect("length") {|value| [value, value.to_s.length] }
    #   lib.collections['length']   # => [nil, nil, nil, ['one', 'two'], nil, :three]
    #
    # Works much like index_by, except that the underlying data store for a 
    # collection is a Collection (ie an array) rather than an Index (a hash).
    def collect(name, &block) # :yields: value
      raise ArgumentError.new("no block given") unless block_given?
      
      collection = Collection.new(&block)
      collections[name] = collection
      collection.stash(values)
    end
    
    # Adds a collection using the attribute or method.  Equivalent to:
    #
    #   lib.collect(attribute) {|value| value.attribute }
    #
    def collect_attribute(attribute)
      method = attribute.to_sym
      collect(attribute) {|value| value.send(method) }
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
    
    # Adds the constants from the specified module.  If mod is a Class, then
    # only constants that are a kind of mod will be added.  This behavior
    # can be altered by providing a block which each constant value; values
    # are only included if the block evaluates to true.
    def add_constants_from(mod)
      const_names = mod.constants.select do |const_name|
        const = mod.const_get(const_name)
        block_given? ? yield(const) : (mod.kind_of?(Class) ? const.kind_of?(mod) : true)
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