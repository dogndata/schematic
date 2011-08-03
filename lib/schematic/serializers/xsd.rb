module Schematic
  module Serializers
    module Xsd
      class << self
        def extended(klass)
          raise InvalidClass unless klass.ancestors.include?(ActiveRecord::Base)
        end
      end

      def schematic(&block)
        schematic_sandbox.run(&block)
      end

      def schematic_sandbox
        @schematic_sandbox ||= Schematic::Generator::Sandbox.new(self)
      end

      def to_xsd(options = {})
        schematic_sandbox.to_xsd(options)
      end

    end
  end
end
