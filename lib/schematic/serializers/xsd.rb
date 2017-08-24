require 'schematic/generator/sandbox'
require 'schematic/exceptions'

module Schematic
  module Serializers
    module Xsd
      def self.extended(klass)
        raise ClassMissingXmlSerializer unless klass.instance_methods.include?(:to_xml)
        raise ClassMissingAttributes unless klass.instance_methods.include?(:attributes)
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
