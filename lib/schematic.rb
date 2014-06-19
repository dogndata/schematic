require 'schematic/version'
require 'schematic/serializers/xsd'

require 'active_record/base'
ActiveRecord::Base.send(:extend, Schematic::Serializers::Xsd)
