# Library provides methods for accesing constants within the 
# including module using lookup and method_missing.  These are 
# ALL convenience methods and will be slower than accessing 
# the constant directly.
module ConstantsLibrary

  # Lookups are hashes that allow quick retrieval of Library items
  # using a key.  Multiple lookups can be specified for a given Library;      
  class Library
    attr_reader :base, :items, :lookups, :collections

    def initialize(base, &block)
      @base = base
      reset(true, &block)
    end

    # Lookup an item by an identifier.  All lookups will be searched 
    # in order; the first matching entry is returned.  If no matches are found,
    # items is searched for an item matching identifier.  If identifier is an 
    # existing item, it will be returned; otherwise the return will be nil. 
    def [](identifier)
      lookups.values.each do |hash|
        item = hash[identifier]
        return item unless item == nil
      end

      items.include?(identifier) ? identifier : nil
    end

    # Clears all items and lookups.  The lookup blocks will only be
    # cleared if specified.
    def clear(complete=false)
      @items = []
      @lookups = {}
      @collections = {}

      if complete
        @lookup_blocks = []
        @collection_blocks = []
      end
    end

    # Resets the items array.  An optional block can be provided to filter
    # the constants in self; false results will be excluded from items.  By
    # default, reset filters all constants that are not a kind of 'base'.
    # Lookup hashes are recalculated with existing lookup blocks.
    def reset(complete=false)
      self.clear(complete)

      items = base.constants.select do |const_name| 
        const = base.const_get(const_name)
        block_given? ? yield(const) : const.kind_of?(base)
      end

      add *items.collect {|const_name| base.const_get(const_name)}
    end

    # Specifies a block to execute when items are added to self.  
    # Existing items are sent to the add_block immediately.
    def on_add(override=false, &block) # :yields: item
      raise "Add block already set!" unless add_block.nil? || override
      @add_block = block
      self.items.each(&block)
      block
    end

    # Add the specified items to self.  New items are indexed using the existing lookups.  
    # Returns the items added (ie items minus any already-existing items).  Nil items
    # cannot be added, and will be quietly ignored.
    def add(*items)
      new_items = items.reject do |item| 
        item == nil || self.items.include?(item)
      end

      self.items.concat(new_items)

      lookup_blocks.each_index do |index| 
        hash_items(new_items, index)
      end

      collection_blocks.each_index do |index| 
        collect_items(new_items, index)
      end

      new_items.each(&add_block) if add_block
      new_items
    end

    def merge!(hash)
      hash.each_pair do |key, item|
        existing = self[key]
        if existing != nil
          items[items.index(existing)] = item
        else
          add(item)
        end
      end

      items = self.items
      self.clear(false)
      add *items
    end

    def lookup_names
      lookup_blocks.collect {|name, block| name}
    end     

    # Adds a lookup to self.  If a block is specified, then it is used to
    # specify keys for  each item in self.
    #
    # return key, [key, value], or false/nil to exclude from collection
    def add_lookup(name, &block) # :yields: item
      if lookup_names.include?(name)
        raise "lookup already exists: #{name}" 
      end

      lookup_blocks << [name, block]
      hash_items(self.items, lookup_blocks.length - 1)
    end

    # Adds lookups for the specified item attributes.
    def add_lookup_by(*attributes)
      attributes.each do |attribute|
        add_lookup(attribute) {|item| item.send(attribute) }
      end
      self
    end

    def collection_names
      collection_blocks.collect {|name, block| name}
    end

    # return item, [item, index], or false/nil to exclude from collection
    def add_collection(name, &block) # :yields: item
      if collection_names.include?(name)
        raise "collection already exists: #{name}" 
      end

      collection_blocks << [name, block]
      collect_items(self.items, collection_blocks.length - 1)
    end

    def add_collection_by(*attributes)
      attributes.each do |attribute|
        add_collection(attribute) {|item| item.send(attribute) }
      end
      self
    end

    protected

    attr_reader :lookup_blocks, :add_block, :collection_blocks

    # Hashes the specified items into lookups using the lookup at lookup_index.
    # Keys are determined by the lookup_block at lookup_index; an error is raised
    # when conflicting keys are specified.
    def hash_items(items, index) # :nodoc:
      name, block = lookup_blocks[index]
      hash = (lookups[name] ||= {})

      items.each_with_index do |item, index| 
        key, value = block.call(item)
        value = item if value == nil

        case 
        when !key then next
        when hash.has_key?(key) 
          raise "lookup '#{name}' already contains key '#{key}'"
        else
          hash[key] = value
        end
      end

      hash
    end

    def collect_items(items, index)
      name, block = collection_blocks[index]      
      array = (collections[name] ||= [])

      items.each do |item| 
        item, index = block.call(item)
        index = array.length if index == nil

        case 
        when !item then next
        when array[index] != nil
          raise "collection '#{name}' already has an item at index '#{index}'"
        else
          array[index] = item
        end
      end

      array
    end
  end

  def self.included(mod)
    mod.extend PublicMethods
    mod.library = Library.new(mod)
  end

  module PublicMethods
    attr_accessor :library

    #
    def [](identifier)
      library[identifier]
    end

    def lookup(name, key)
      library.lookups[name][key]
    end

    def collection(name)
      library.collections[name]
    end
  end
end