module Schematic
  class ClassMissingXmlSerializer < Exception
    def message
      'This class does not include ActiveModel::Serializers::Xml. You cannot generate an XSD from it.'
    end
  end

  class ClassMissingAttributes < Exception
    def message
      'This class does not implement #attributes. You cannot generate an XSD from it.'
    end
  end
end
