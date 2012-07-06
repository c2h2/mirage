require 'youtube_it'
require_relative 'conf/dev_key.rb'
require 'mongoid'
Dir[File.dirname(__FILE__) + '/model/*.rb'].each {|file| puts "Requiring #{file}"; require file }
require_relative 'conf/conf.rb'
require_relative 'lib/aux.rb'
require_relative 'conf/db.rb'
require 'pp'


yt=You2.new
videos = yt.uploader_all_videos ARGV[0]
videos.each do |v|
  Util.log "#{v.author.name}|#{v.title}|#{v.unique_id}"
  unless Youtube.exists?(v.unique_id)
    Util.log "Adding youtube video"
    y=Youtube.new
    y.yid = v.unique_id
    y.title = v.title
    y.uploader= v.author.name
    y.if_download = true
    y.downloaded = false
    y.save
  end
end
