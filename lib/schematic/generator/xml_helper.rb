module Schematic
  module Generator
    module XmlHelper
      def header(builder)
        builder.instruct!
      end

      def ns(ns, provider, key)
        { "xmlns:#{ns}" => Namespaces::PROVIDERS[provider][key] }
      end
    end
  end
end
