require 'mongoid'
Dir[File.dirname(__FILE__) + '/model/*.rb'].each {|file| puts "Requiring #{file}"; require file }
require_relative 'conf/conf.rb'
require_relative 'lib/aux.rb'
require_relative 'conf/db.rb'
require 'open-uri'
require 'json'
require 'pp'

JSON_DIR = 'json_info'
loop do 
  ys = Youtube.where(:info_saved => false).limit(10)
  ys.each do |y|
    begin
      url = "http://www.youtube.com/watch?v=#{y.yid}"
      `cd #{JSON_DIR} && ../youtube-dl/youtube-dl --skip-download --write-info-json  '#{url}'`
      json_fn = `ls #{JSON_DIR}/#{y.yid}*`.strip
      json = JSON.parse File.read(json_fn)
      y.thumb = json["thumbnail"]
      y.title = json["title"]
      y.uploader = json["uploader"]
      y.info_saved = true
      y.save
  
      Util.log "#{y.uploader}|#{y.title}|#{y.thumb}"
    rescue
      #something wrong on extracting info
      Util.log "Soemthing wrong with extraction."
    end
  end
  Util.log "No more jobs. Sleeping"
  sleep 5
end
