require 'mongoid'

#Mongoid.load!("./db.yml")
#Moped::Session.new(["localhost:27017"])
Mongoid.configure do |config|
  name = "asdf"
  host = "localhost"
  port = 27017
  config.database = Mongo::Connection.new.db(name)

end
