module Schematic
  module Serializers
    module Xsd
      class << self
        def extended(klass)
          raise InvalidClass unless klass.ancestors.include?(ActiveRecord::Base)
        end
      end

      def xsd_generator
        @xsd_generator ||= Schematic::Generator::Xsd.new(self)
      end

      def to_xsd(options = {})
        output = ""
        builder = Builder::XmlMarkup.new(:target => output, :indent => 2)
        xsd_generator.options = options
        xsd_generator.header(builder)
        xsd_generator.schema(builder)
        output
      end

      def generate_xsd(builder, klass, options)
        xsd_generator.options = options
        xsd_generator.generate(builder, klass)
      end

      def xsd_methods
        {}
      end

      def xsd_ignore_methods
        []
      end

    end
  end
end
