require 'constants/constant_library'

module Constants

  # Library adds methods for convenient indexing and access of constants
  # in a module.  Usually Library is included after the constants have
  # been defined.
  #
  #   module Color
  #     RED = 'red'
  #     GREEN = 'green'
  #     BLUE = 'blue'
  #     GREY = 'grey'
  #
  #     include Constants::Library
  #     library.index_by('name') {|c| c }
  #   end
  #
  # Now the Color constants can be accessed through the indicies hash
  # or through [], which searches all indicies for the first match.
  #
  #   Color.index('name')
  #   # => {
  #   # 'red' => Color::RED,
  #   # 'blue' => Color::BLUE,
  #   # 'green' => Color::GREEN,
  #   # 'grey' => Color::GREY}
  #
  #   Color['red']                  # => Color::RED
  #
  # Indexing is simplified for attributes.  Notice that multiple
  # values matching the same key are stashed into one group:
  #
  #   Color.library.index_by_attribute 'length'
  #   Color.index('length')
  #   # => {
  #   # 3 => Color::RED,
  #   # 4 => [Color::BLUE, Color::GREY],
  #   # 5 => Color::GREEN}
  #
  #   Color[4]                      # => [Color::BLUE, Color::GREY]
  #
  # Constants may also be assembled into ordered collections, which
  # may or may not contain all the constants.
  #
  #   Color.library.collect('gstar') {|c| c =~ /^g/ ? c : nil }
  #   Color.collection('gstar')     # => [Color::GREEN, Color::GREY]
  #
  #   Color.library.collect_attribute 'length'
  #   Color.collection('length')    # => [3,5,4,4]
  #
  # New constants (even 'constants' that are not declared in the module) may be
  # added manually, or by resetting the library.  All indexes and collections
  # are updated automatically.
  #
  #   Color.library.add('yellow')
  #   Color.index('length')
  #   # => {
  #   # 3 => Color::RED,
  #   # 4 => [Color::BLUE, Color::GREY],
  #   # 5 => Color::GREEN,
  #   # 6 => 'yellow'}
  #
  #   module Color
  #     ORANGE = 'orange'
  #     reset_library
  #   end
  #
  #   Color.index('length')   
  #   # => {
  #   # 3 => Color::RED,
  #   # 4 => [Color::BLUE, Color::GREY],
  #   # 5 => Color::GREEN,
  #   # 6 => Color::ORANGE}
  #
  # Notice 'yellow' was removed when the library was reset.  The yellow example
  # illustrates the fact that library only tracks the values of constants, not
  # the constants themselves.  If, for some reason, you dynamically reset a constant
  # value then the change will not be reflected in the library until the library
  # is reset.
  #
  # ==== Ruby 1.8
  # Ruby doesn't track of the order of constant declaration until Ruby 1.9... this
  # may cause collected values to be re-ordered in an unpredictable fashion.  For
  # instance in the Color example:
  #
  #   Color[4] # may equal [Color::BLUE, Color::GREY] or [Color::GREY, Color::BLUE].
  #
  # In any case, the constants will be ordered as in Color.constants.
  #
  # == Performance Considerations
  # ConstantsLibrary makes access of constants easier, but at the expense of
  # performance.  Naturally the constant itself is the highest-performing
  # way of accessing the constant value.
  #
  module Library
    
    # Accesses the module constant library.
    attr_accessor :library
    
    def self.included(mod)
      mod.extend self
    end
    
    def self.extended(mod)
      mod.library = ConstantLibrary.new
      mod.reset_library
    end
    
    # Alias for library[identifier] (see Constants::ConstantLibrary#[])
    def [](identifier)
      library[identifier]
    end
    
    # Returns the index by the specified name.
    def index(name)
      library.indicies[name]
    end
    
    # Returns the collection by the specified name.
    def collection(name)
      library.collections[name]
    end
    
    # Resets the library using constants from self.  A block
    # can be provided to filter constants, see 
    # Constants::ConstantLibrary#add_constants_from
    def reset_library(&block)
      library.clear
      library.add_constants_from(self, &block)
    end
  end
end