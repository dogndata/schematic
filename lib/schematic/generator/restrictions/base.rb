module Schematic
  module Generator
    module Restrictions
      class Base < Schematic::Generator::ColumnValidator
        def self.inherited(klass)
          Schematic::Generator::Column.restriction_classes << klass unless Schematic::Generator::Column.restriction_classes.include?(klass)
        end
      end
    end
  end
end
