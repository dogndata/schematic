module Schematic
  module Generator
    class Sandbox
      attr_accessor :ignored_elements, :added_elements, :required_elements

      def initialize(klass)
        @klass = klass
        @ignored_elements ||= []
        @added_elements ||= {}
        @required_elements ||= []
      end

      def run(&block)
        instance_eval &block
      end

      def xsd_generator
        @xsd_generator ||= Schematic::Generator::Xsd.new(@klass)
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

      def ignore(*fields)
        fields.each { |field| ignored_elements << field }
      end

      def add(*args)
        name = args.shift
        if name.is_a? Hash
          added_elements[name.keys.first] = name.values.first
        else
          added_elements[name] = nil
        end
      end

      def required(*fields)
        fields.each { |field| required_elements << field }
      end

      def method_missing(method, *args, &block)
        @klass.send method, *args, &block
      end
    end
  end
end
