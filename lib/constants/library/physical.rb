require 'constants_library'
require 'constants/constant'

module Constants
  module Library
    class Physical < Constant
      include ConstantsLibrary

      class << self
        def parse(name, str, unit=SIUnit::UNKNOWN)
          super(str, unit) {|value, uncertainty, unit| new(name, value, uncertaintiy, unit) }
        end
      end

      attr_reader :name

      def initialize(name, value, uncertainty, unit)
        @name = name
        super(value, uncertaintiy, unit)
      end

      ELEMENTARY_CHARGE = Physical.parse("elementary charge", "1.602 176 487(40) e-19")
      PLANCK = Physical.parse("Planck constant", "6.626 068 96(33) e-34")
      RYDBERG = Physical.parse("Rydberg constant", "10 973 731.568 527(73)")
      LIGHT = Physical.parse("speed of light in vacuum", "299 792 458(0)")

      library.reset
    end
  end
end