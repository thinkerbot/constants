require 'constants/uncertainty'
require 'ruby_units'

module Constants

  class Constant 
    include Comparable

    class << self

      # Parses the common notation '<value>(<uncertainty>)' into a value and
      # an uncertainty. When no uncertainty is specified, the uncertainty is nil.  
      # Whitespace is allowed.
      #
      #  Base.parse("1.0(2)").vu                             # => [1.0, 0.2]
      #  Base.parse("1.007 825 032 1(4)").vu      # => [1.0078250321, 0.0000000004]
      #  Base.parse("6.626 068 96").vu                # => [6.62606896, nil]
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

    attr_reader :value, :uncertainty, :unit

    def initialize(value, unit=nil, uncertainty=Uncertainty::UNKNOWN)
      @value = value
      @unit = unit.to_s.strip.empty? ? nil : Unit.new(unit)
      @uncertainty = uncertainty
    end
    
    def <=>(another)
      value <=> another.value
    end
    
    def to_a
      [value, uncertainty]
    end
  end

end