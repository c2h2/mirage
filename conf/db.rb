require 'mongoid'

### mongo conn ###
Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("mirage_test00")
end
