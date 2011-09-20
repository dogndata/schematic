module Schematic
  class ClassMissingXmlSerializer < Exception
    def message
      "This class does not include ActiveModel::Serializers::Xml. You cannot generate an XSD from it."
    end
  end

  class ClassMissingAttributes < Exception
    def message
      "This class does not implement #attributes. You cannot generate an XSD from it."
    end
  end

  module Generator
    autoload :XmlHelper, 'schematic/generator/xml_helper'
    autoload :Sandbox, 'schematic/generator/sandbox'
    autoload :Xsd, 'schematic/generator/xsd'
    autoload :Names, 'schematic/generator/names'
    autoload :Namespaces, 'schematic/generator/namespaces'
    autoload :Column, 'schematic/generator/column'
    autoload :ColumnValidator, 'schematic/generator/column_validator'
    autoload :Types, 'schematic/generator/types'
    autoload :Uniqueness, 'schematic/generator/uniqueness'
    autoload :Wsdl, 'schematic/generator/wsdl'

    module Restrictions
      autoload :Base, 'schematic/generator/restrictions/base'
      autoload :Custom, 'schematic/generator/restrictions/custom'
      autoload :Enumeration, 'schematic/generator/restrictions/enumeration'
      autoload :Length, 'schematic/generator/restrictions/length'
      autoload :Pattern, 'schematic/generator/restrictions/pattern'
      autoload :Numericality, 'schematic/generator/restrictions/numericality'
    end
  end
  module Serializers
    autoload :Xsd, 'schematic/serializers/xsd'
  end

  autoload :Version, 'schematic/version'
end

require "builder"
require 'active_support/inflector/inflections'
require 'active_support/inflections'

ActiveRecord::Base.send(:extend, Schematic::Serializers::Xsd)
