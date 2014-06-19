require 'active_record'

is_jruby = RUBY_PLATFORM =~ /\bjava\b/
adapter = is_jruby ? 'jdbcsqlite3' : 'sqlite3'

ActiveRecord::Base.establish_connection({
  :adapter => adapter,
  :database => ':memory:',
})
