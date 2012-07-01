require 'mongoid'
Dir[File.dirname(__FILE__) + '/model/*.rb'].each {|file| puts "Requiring #{file}"; require file }
require_relative 'conf/conf.rb'
require_relative 'lib/aux.rb'
require_relative 'conf/db.rb'
require 'yaml'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'pp'


class Mirage
  
  def initialize
    @cnt = 0
    @urlmd5s={}
    pre_warm if PRE_WARM
    run
  end

  def run
    loop do
      process_one_link
    end
  end
  def process_one_link
    link = get_a_link
    #if link is accquired successful
    unless link.nil?
      #processing page now
      page = dl link
     
      link.state = LINK_STATE_PROCESSED
      link.save
      #if page is dl'ed successful
      process_one_page page, link.url
    else
      Util.log "no more job, sleep for a while"
      sleep 0.01
    end
  end
  
  def process_one_page page, org_link
    Util.log "Getting a page #{page.url}"
    if !page.url.nil?
      urls = page.parse_page
      
      if Youtube.valid_video?(page.url)
        yid = Youtube.get_yid(page.url)
        title = page.get_youtube_title
        new_youtube(yid, page, title)
      end
    
      if urls.nil?
        #do nothing, since no page.
      else
        urls.each do |url|
          save_url page, url
        end
      end
      
      begin
        page.state = PAGE_STATE_PROCESSED
        page.save
      rescue
        #save utf-8 invliad problems.
      end
    else
      Util.log "Empty queue, sleep for a while"
      sleep 0.5
    end
  end

  def valid_url? url
    (url.to_s =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix)
  end

  def get_hash url
    Util.hexmd5 url
  end

  def pre_warm
    Util.log "PRE WARMING"
    cnt =0
    Link.all.each do |link|
      @urlmd5s[get_hash(link.url)]=true
      cnt +=1
    end
    Util.log "#{cnt} loaded into hash urls."
    
  end

  def has_url? url
    md5=get_hash(url)
    if @urlmd5s[md5].nil?
      @urlmd5s[md5]=true
      return false
    else
      return true
    end
  end

  def new_youtube yid, page=nil, title=nil
    Util.log "NEW YOUTUBE #{yid}"
    if Youtube.exists?(yid)
      y=Youtube.where(:yid => yid).first
      if page.nil? and title.nil?
         #nothing to do
      else
        y.page = page unless page.nil?
        y.title = title unless title.nil?
      end
    else
      y = Youtube.new
      y.yid = yid
      unless page.nil?
        y.page = page
      end
      unless title.nil?
        y.title = title
      end
    end
    y.state = LINK_STATE_UNPROCESSED
    y.info_saved = false
    y.save
  end

  def save_url page, org_url
    #determine if valid
    url = Link.full_url(page.url, org_url)
    if has_url? url
      Util.log("Duplicated url from HASH.")
    end
    unless valid_url?(url)
      Util.log "Non valid url, #{url}"
      return
    end
    #determine if intersted. (domain, regex, and similarity)
    unless Rule.ok?(url)
      #return
    end
    return if Rule.domain(url) != "www.youtube.com"

    if Youtube.valid_video?(url)
      yid = Youtube.get_yid(url)
      new_youtube(yid)
    end

    unless PRE_WARM
      if Link.exists? url
        Util.log("Duplicated url from MONGO.")
        return
      end
    end
  
    Util.log "Saved #{url}"
    l=Link.new
    l.url = url 
    l.depth = page.link.depth + 1 rescue nil
    l.state = LINK_STATE_UNPROCESSED
    l.save
  end

  def dl link, remain_times = 2
    return unless link.is_a? Link
    page = Page.new
    page.state = PAGE_STATE_UNPROCESSED
    if remain_times <= 0
      Util.log "Error in DL #{link.url} really failed after #{3} times"
      return 
    end
    page.link = link
    Util.log "DL #{link.url}"
    hash = {"User-Agent" => UAS.sample} #put UA here
    sw=Stopwatch.new 
    
    begin
      Timeout::timeout(15) do
        open(link.url, hash) do |f|
          page.url     = link.url
          page.content = f.read
          page.charset = f.charset
          page.mime    = f.content_type
          page.code    = f.status[0].to_i
          page.link    = link
          f.base_uri
          f.meta
          begin
            page.expires_at = Time.parse(f.meta["expires"])
          rescue => e
            #no expires found
          end
  
          begin
            page.etag = f.meta["etag"]
          rescue => e
            #no etag found
          end
    
          unless f.last_modified.nil?
            page.lm_at = f.last_modified
          end
        end
        page.resp_ms =  (sw.end * 1000).floor
      end
      Util.log "dl #{link.url} successfully, #{page.content.length} bytes dl'ed."
    rescue => e
      Util.log "Error in dl|#{link.url}|RETRYING#{remain_times - 1}|#{e}"
      dl(link, remain_times - 1)
    end
    page.save
    page
  end

  def get_a_link
    Link.where(:state => LINK_STATE_UNPROCESSED).limit(1).first
  end
end

class MirageWorker
  def self.downloader
    loop do
      ys = Youtube.where(:downloaded => false).limit(10)
      ys.each do |y|
        begin
          url = "http://www.youtube.com/watch?v=#{y.yid}"
          Util.log "Processing #{y.yid}"
          cmd = "cd #{DL_DIR} && #{HTTP_PROXY} ../youtube-dl/youtube-dl -t '#{url}'"
          Util.log cmd
          Util.log `#{cmd}`
          dl_fn = `ls #{DL_DIR}/*#{y.yid}*`.strip
          y.downloaded = true
          y.fn = dl_fn
          y.save
  
          Util.log "#{y.fn}"
        rescue => e
          #something wrong on extracting info
          Util.log "Soemthing wrong with extraction. #{e}"
        end
      end
    end
    Util.log "Sleeping"
    sleep 5
  end


  def self.info_extract
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
    end
    Util.log "Sleeping"
    sleep 5
  end
end



def usage
  usage ="==USAGE==\n"

  usage += "ruby mirage.rb seed = seed an initial link to db (should run this first time)\n"
  usage += "ruby mirage.rb run  = run the crawler\n"
  usage += "ruby mirage.rb list = list all the counts (youtubes, links, pages)\n"
  usage += "ruby mirage.rb extract = using youtube-dl to extract all the info\n"
  usage += "ruby mirage.rb dl = using youtube-dl to dl videos\n"
end

def start
  if ARGV[0].nil?
    puts usage()
  elsif ARGV[0]=="run"
    m=Mirage.new
  elsif ARGV[0]=="seed"
    Youutube.destroy_all
    Link.destroy_all
    Page.destroy_all
    l=Link.new
    l.url = ARGV[1].nil? ? 'http://www.youtube.com/watch?v=AgJcn4VKtp0&feature=g-all-u' : ARGV[1]
    l.state = LINK_STATE_UNPROCESSED
    l.save
  elsif ARGV[0]=="list"
    puts "Youtubes:" + Youtube.count.to_s
    puts "Links:" + Link.count.to_s
    puts "Pages:" + Page.count.to_s
  elsif ARGV[0]=="extract"
    MirageWorker.info_extract
  elsif ARGV[0]=="dl"
    MirageWorker.downloader    
  end
end


start
