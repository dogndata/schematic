# [Schematic](http://github.com/casecommons/schematic/)

## Description

Automatic XSD generation for your ActiveRecord models

## Install

Add schematic to your Gemfile

```ruby
gem 'schematic'
```

Then run:

```
$ bundle install
```

## Usage
  
```ruby
class Post < ActiveRecord::Base
end

Post.to_xsd => (a bunch of xml)
```

Validations will automatically add restrictions to the XSD for fields. If a validation has a conditional if or unless option it will be skipped. However if you wish to force the inclusion of the validation in the XSD you can set: `{ :xsd => { :include => true } }` in the options e.g.

```ruby
class Post < ActiveRecord::Base
  validates :category, :inclusion => { :in => ["foo", "bar"], :xsd => { :include => true } }, :if => lambda { ... }
end
```

You can include or exclude additional elements:

```ruby
class Post < ActiveRecord::Base
  schematic do
    element :title
    element :author => [:name, :email, :url]
    element :blog => { :post => { :category => nil } }
    ignore :comments
    ignore :attachments => [:filetype]
  end
end
```

You can also change the name of the root tag:

```ruby
class Post < ActiveRecord::Base
  schematic do
    root "blog-post"
  end
end
```

If you want to programatically include or exclude elements use `Post#schematic_sandbox.added_elements` and `Post#schematic_sandbox.ignored_elements`.

The former is a Hash and the latter is an Array.

You can define your own custom restrictions by inheriting from the Restrictions Base class:

```ruby
class MyCustomRestriction < Schematic::Generator::Restrictions::Base
  def generate(builder)
    for_validator ActiveModel::BlockValidator do |validator|
      builder.xs(:enumeration, "value" => "foo")
      builder.xs(:enumeration, "value" => "bar")
    end
  end
end
```

You can have a custom pattern restriction from a custom validater:

```ruby
class MyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # ...
  end

  def xsd_pattern_restrictions
    [/foo/, /bar/]
  end
end
```

You can have a custom enumeration restriction from a custom validater:

```ruby
class MyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    ...
  end

  def xsd_field_enumeration_restrictions
    ["foo", "bar"]
  end
end
```

## Requirements

- ActiveRecord 4.x

## License

MIT
