require 'schematic/version'
require 'schematic/serializers/xsd'

require 'activemodel-serializers-xml'
require 'active_record/base'
ActiveRecord::Base.send(:extend, Schematic::Serializers::Xsd)
