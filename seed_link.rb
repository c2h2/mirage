require_relative 'conf/db.rb'
require_relative 'model/models.rb'
require_relative 'conf/conf.rb'

Link.destroy_all
Page.destroy_all
l=Link.new
l='http://www.youtube.com/watch?v=AgJcn4VKtp0&feature=g-all-u'
l.save
