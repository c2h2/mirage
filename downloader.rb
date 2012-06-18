require 'mongoid'
Dir[File.dirname(__FILE__) + '/model/*.rb'].each {|file| puts "Requiring #{file}"; require file }
require_relative 'conf/conf.rb'
require_relative 'lib/aux.rb'
require_relative 'conf/db.rb'
require 'open-uri'
require 'json'
require 'pp'

HTTP_PROXY = "http_proxy=http://localhost:1095"
DL_DIR = 'dl'
loop do 
  ys = Youtube.where(:downloaded => false).limit(10)
  ys.each do |y|
    begin
      url = "http://www.youtube.com/watch?v=#{y.yid}"
      Util.log "Processing #{y.yid}"
      `cd #{DL_DIR} && #{HTTP_PROXY} ../youtube-dl/youtube-dl -t '#{url}'`
      dl_fn = `ls #{DL_DIR}/#{y.yid}*`.strip
      y.uploader = json["uploader"]
      y.downloaded = true
      y.fn = dl_fn
      y.save
  
      Util.log "#{y.fn}"
        rescue
      #something wrong on extracting info
      Util.log "Soemthing wrong with extraction."
    end
  end
  Util.log "Sleeping"
  sleep 5
end
