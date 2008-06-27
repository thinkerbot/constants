require 'constants/constant_library'

module Constants

  # Library adds a library attribute to a module allowing
  # convenient indexing and access of constants in the module.
  #
  #   module Color
  #     include Constants::Library
  #   
  #     RED = 'red'
  #     GREEN = 'green'
  #     BLUE = 'blue'
  #     GREY = 'grey'
  #
  #     library.index_by 'name' {|c| c }
  #   end
  #
  # Now the color constants can be accessed through the index hash,
  # through [] (which searches all indexes for the first match), or
  # through a module accessor (provided there is no conflicting
  # method).
  #
  #   Color.indicies['name']
  #   # => {
  #   # 'red' => Color::RED,
  #   # 'blue' => Color::BLUE,
  #   # 'green' => Color::GREEN,
  #   # 'grey' => Color::GREY}
  #
  #   Color['red']                # => Color::RED
  #   Color.red                   # => Color::RED
  #
  # Indexing is simplified for attributes.  Notice that multiple
  # values matching the same key are grouped:
  #
  #   Color.library.index_by_attribute 'length', :reader => false
  #   Color.indicies['length']      
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
  #   Colors.library.collect_by 'grb' {|c| ['green', 'red', 'blue'].index(c) }
  #   Colors.collections['grb']
  #   # => [Color::GREEN, Color::RED, Color::BLUE]
  #
  #   Colors.library.collect_by_attribute 'length'
  #   Colors.collections['length']
  #   # => [nil, nil, nil, Color::RED, [Color::BLUE, Color::GREY], Color::GREEN]
  #
  # New constants (even 'constants' that are not declared in the module) may be
  # added manually, or by resetting the library.  All indexes and collections
  # are updated automatically.
  #
  #   Color.library.add('yellow')
  #   Color.indicies['length']      
  #   # => {
  #   # 3 => Color::RED,
  #   # 4 => [Color::BLUE, Color::GREY],
  #   # 5 => Color::GREEN,
  #   # 6 => Color::YELLOW}
  #
  #   module Color
  #     ORANGE = 'orange'
  #     library.reset
  #   end
  #
  #   Color.indicies['length']      
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
  #--
  # == Performance Considerations
  # ConstantsLibrary makes access of constants easier, but at the expense of
  # performance.  Naturally the constant itself is the highest-performing
  # way of accessing the constant value.  Performance stacks up like this:
  #
  #   method        relative time per 1M calls
  #   Color::RED    1
  #   Color.red    
  #   Color['red'] 
  #
  # The [] method is always going to be slowest since it is a simple search of
  # all the available keys.
  #
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
      library.add_from(self)
    end
    
  end
end