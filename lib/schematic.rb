module Schematic
  class InvalidClass < Exception
    def message
      "This class does not include ActiveModel. You cannot generate an XSD from it."
    end
  end
end

require "builder"

require 'active_support/inflector/inflections'
require 'active_support/inflections'
require "schematic/serializers/xsd"

ActiveRecord::Base.send(:extend, Schematic::Serializers::Xsd)
