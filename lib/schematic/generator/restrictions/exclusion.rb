module Schematic
  module Generator
    module Restrictions
      class Exclusion < Base
        def generate(builder)
          for_validator ActiveModel::Validations::ExclusionValidator do |validator|
            if exclusions = validator.options[:in]
              exclusions.each do |exclusion|
                builder.xs(:pattern, "value" => "[^(#{exclusion})].*")
              end
            end
          end
        end
      end
    end
  end
end


