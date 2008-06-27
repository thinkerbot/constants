require 'constants/constant_library'

module Constants

  # Library adds a library to a class or module allowing
  # convenient indexing and access of constants therein.
  #
  #   module Color
  #     include Constants::Library
  #   
  #     RED = 'red'
  #     GREEN = 'green'
  #     BLUE = 'blue'
  #     GREY = 'grey'
  #
  #     library.index_by('name') {|c| c }
  #     reset_library
  #   end
  #
  # Now the color constants can be accessed through the indicies hash
  # or through [], which searches all indicies for the first match.
  #
  #   Color.index('name')
  #   # => {
  #   # 'red' => Color::RED,
  #   # 'blue' => Color::BLUE,
  #   # 'green' => Color::GREEN,
  #   # 'grey' => Color::GREY}
  #
  #   Color['red']                # => Color::RED
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
  #   Color[4]                    # => [Color::BLUE, Color::GREY]
  #
  # Constants may also be assembled into ordered collections, which
  # may or may not contain all the constants.
  #
  #   Color.library.collect_by('rgb') {|c| ['green', 'red', 'blue'].include?(c) ? c : nil }
  #   Color.collection('rgb')
  #   # => [Color::RED, Color::GREEN, Color::BLUE]
  #
  #   Color.library.collect_by_attribute 'length'
  #   Color.collection('length')
  #   # => [nil, nil, nil, Color::RED, [Color::BLUE, Color::GREY], Color::GREEN]
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
  # illustrates the fact that library only tracks the _values_ of constants, not
  # the constants themselves.  If, for some reason, you dynamically reset a constant
  # value then the change will not be reflected in the library until the library
  # is reset.
  #
  # == Performance Considerations
  # ConstantsLibrary makes access of constants easier, but at the expense of
  # performance.  Naturally the constant itself is the highest-performing
  # way of accessing the constant value.  
  module Library
    
    # Accesses the module constant library.
    attr_accessor :library
    
    def self.included(mod)
      mod.extend self
    end
    
    def self.extended(mod)
      mod.library = ConstantLibrary.new
    end

    def [](identifier)
      library[identifier]
    end
    
    def index(name)
      library.indicies[name]
    end
    
    def collection(name)
      library.collections[name]
    end
    
    protected
    
    def reset_library
      library.clear
      library.add_from(self)
    end
    
  end
end