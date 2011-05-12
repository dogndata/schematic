module Schematic
  module Generator
    module Restrictions
      class Custom < Base
        def generate(builder)
          validators_for_column.each do |validator|
            if validator.respond_to?(:xsd_pattern_restrictions)
              validator.xsd_pattern_restrictions.each do |restriction|
                builder.xs(:pattern, "value" => restriction.is_a?(Regexp) ? restriction.source : restriction)
              end
              return
            end
          end
        end
      end
    end
  end
end

