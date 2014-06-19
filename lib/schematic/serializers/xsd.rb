require 'schematic/generator/sandbox'

module Schematic
  module Serializers
    module Xsd
      def self.extended(klass)
        raise ClassMissingXmlSerializer unless klass.ancestors.include?(ActiveModel::Serializers::Xml)
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
