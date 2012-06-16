require_relative 'conf/db.rb'
require_relative 'conf/conf.rb'
Dir[File.dirname(__FILE__) + '/model/*.rb'].each {|file| puts "Requiring #{file}"; require file }

Link.destroy_all
Page.destroy_all
l=Link.new
l.url = 'http://www.youtube.com/watch?v=AgJcn4VKtp0&feature=g-all-u'
l.state = LINK_STATE_UNPROCESSED
l.save


ls= Link.all
ls.each do |l|
  puts l.url
end
