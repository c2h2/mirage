require 'mongoid'
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| puts "Requiring #{file}"; require file }
require_relative 'conf/conf.rb'
require_relative 'lib/aux.rb'
require 'yaml'
require 'open-uri'


class Mirage
  
  def initialize host
    @cnt = 0
    run
  end

  def run
    loop do
      process_one_link
    end
  end

  def submit_to_server
    #write back to rabbitmq
    pp = @page
    begin
      ypage = pp.to_yaml
      @exch2.publish(ypage, :key=>"pages")
    rescue 
      #avoid some UTF8 convert error.
    end
  end

  def process_one_link
    link = get_a_job
    #if link is accquired successful
    unless link.nil?
      @page = dl link
      #if page is dl'ed successful
      submit_to_server 
    else
      Util.log "no more job, sleep for a while"
      sleep 0.01
    end
  end

  def dl link, remain_times = 2
    return unless link.is_a? Link
    @page = PagePort.new
    if remain_times <= 0
      Util.log "Error in DL #{link.url} really failed after #{3} times"
      return 
    end
    #@page.link = link #might need to fix here as portable won't transfer
    Util.log "DL #{link.url}"
    hash = {} #put UA here
    sw=Stopwatch.new 
    
    begin
      Timeout::timeout(5) do
        open(link.url, hash) do |f|
          @page.url     = link.url
          @page.content = f.read
          @page.charset = f.charset
          @page.mime    = f.content_type
          @page.code    = f.status[0].to_i
          f.base_uri
          f.meta
          begin
            @page.expires_at = Time.parse(f.meta["expires"])
          rescue => e
            #no expires found
          end
  
          begin
            @page.etag = f.meta["etag"]
          rescue => e
            #no etag found
          end
    
          unless f.last_modified.nil?
            @page.lm_at = f.last_modified
          end
        end
        @page.resp_ms =  (sw.end * 1000).floor
      end
      Util.log "dl #{link.url} successfully, #{@page.content.length} bytes dl'ed."
    rescue => e
      Util.log "Error in dl|#{link.url}|RETRYING#{remain_times - 1}|#{e}"
      dl(link, remain_times - 1)
    end
    @page
  end

  def get_a_job
    item = @queue.pop
    puts "Queue length = #{@queue.message_count}"
    if item[:payload].is_a? String
      link = YAML::load item[:payload]
    else
      link = nil
    end
    link
  end



end

lw=Linkworker.new RABBIT_HOST
lw.run

