module Schematic
  module Generator
    module Restrictions
      class Custom < Base
        def generate(builder)
          validators_for_column.each do |validator|
            if validator.respond_to?(:xsd_restriction)
              restriction = validator.xsd_restriction
              builder.xs(:pattern, "value" => restriction.is_a?(Regexp) ? restriction.source : restriction)
              return
            end
          end
        end
      end
    end
  end
end

