require 'constants/uncertainty'
require 'constants/library'
require 'rubygems'
require 'ruby-units'

# Adds several units to {ruby-units}[http://rubyforge.org/projects/ruby-units] for use
# in reporting physical constant data.  See the README.
class Unit < Numeric
  
  # Relationships from: http://www.physics.nist.gov/cuu/Constants/Table/allascii.txt
  # Date: Mon Apr 28 21:09:29 -0600 2008
  # ELECTRON_VOLT_JOULE            = ['electron-volt', 'joule', '1.602176487e-19', 'J', '0.000000040e-19']
  # KELVIN_JOULE                   = ['kelvin',        'joule', '1.3806504e-23',   'J', '0.0000024e-23']
  # HARTREE_JOULE                  = ['hartree',       'joule', '4.35974394e-18',  'J', '0.00000022e-18']
  
  UNIT_DEFINITIONS['<electron-volt>'] = [%w{eV}, 1.602176487e-19, :energy, %w{<meter> <meter> <kilogram>}, %w{<second> <second>}]
  UNIT_DEFINITIONS['<kelvin>'] = [%w{K}, 1.3806504e-23, :energy, %w{<meter> <meter> <kilogram>}, %w{<second> <second>}]
  UNIT_DEFINITIONS['<hartree>'] = [%w{E_h}, 4.35974394e-18, :energy, %w{<meter> <meter> <kilogram>}, %w{<second> <second>}]
end
Unit.setup

module Constants
  
  # Constant tracks the value, uncertainty, and unit of measurement for a
  # measured quantity.  Units are tracked via {ruby-units}[http://rubyforge.org/projects/ruby-units].
  class Constant 
    include Comparable

    class << self

      # Parses the common notation '<value>(<uncertainty>)' into a value and
      # an uncertainty. When no uncertainty is specified, the uncertainty is nil.  
      # Whitespace is allowed.
      #
      #  Base.parse("1.0(2)").vu                    # => [1.0, 0.2]
      #  Base.parse("1.007 825 032 1(4)").vu        # => [1.0078250321, 1/2500000000]
      #  Base.parse("6.626 068 96").vu              # => [6.62606896, nil]
      #
      def parse(str)
        str = str.to_s.gsub(/\s/, '')
        raise "cannot parse: #{str}" unless str =~ /^(-?\d+)(\.\d+)?(\(\d+\))?(e-?\d+)?(.*)$/

        value = "#{$1}#{$2}#{$4}".to_f
        unit = $5
        uncertainty = case
        when $3 == nil then nil
        else
          factor = $2 == nil ? 0 : 1 - $2.length
          factor += $4[1..-1].to_i unless $4 == nil
          $3[1..-2].to_i * 10 ** factor
        end

        block_given? ? yield(value, unit, uncertainty) : new(value, unit, uncertainty)
      end
    end
    
    # The measured value of the constant
    attr_reader :value
    
    # The uncertainty of the measured value.  May be exact or unknown,
    # represented by Uncertainty::EXACT (0) and Uncertainty::UNKNOWN 
    # (nil) respectively.
    attr_reader :uncertainty
    
    # The units of the measured value, may be nil for unitless constants
    attr_reader :unit

    def initialize(value, unit=nil, uncertainty=Uncertainty::UNKNOWN)
      @value = value
      @unit = unit.to_s.strip.empty? ? nil : Unit.new(unit)
      @uncertainty = uncertainty
    end
    
    # For Numeric inputs, compares value to another.  For all other inputs,
    # peforms the default == comparison.
    def ==(another)
      case another
      when Numeric then value == another
      else super(another)
      end
    end
    
    # Compares the value of another to the value of self.
    def <=>(another)
      value <=> another.value
    end
    
    # Returns the array: [value, uncertainty]
    def to_a
      [value, uncertainty]
    end
  end

end