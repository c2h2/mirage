require_relative 'conf/db.rb'
require_relative 'conf/conf.rb'
Dir[File.dirname(__FILE__) + '/model/*.rb'].each {|file| puts "Requiring #{file}"; require file }


ls= Link.all
ls.each do |l|
  puts l.url
end