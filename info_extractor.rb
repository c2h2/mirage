require 'mongoid'
Dir[File.dirname(__FILE__) + '/model/*.rb'].each {|file| puts "Requiring #{file}"; require file }
require_relative 'conf/conf.rb'
require_relative 'lib/aux.rb'
require_relative 'conf/db.rb'
require 'open-uri'
require 'json'
require 'pp'

HTTP_PROXY = "http_proxy=http://localhost:1095"
JSON_DIR = 'json_info'
loop do 
  ys = Youtube.where(:info_saved => false).limit(10)
  ys.each do |y|
    begin
      url = "http://www.youtube.com/watch?v=#{y.yid}"
      Util.log "Processing #{y.yid}"
      `cd #{JSON_DIR} && #{HTTP_PROXY} ../youtube-dl/youtube-dl --skip-download --write-info-json  '#{url}'`
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
  Util.log "Sleeping"
  sleep 5
end
