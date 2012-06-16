require 'mongoid'
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| puts "Requiring #{file}"; require file }
require_relative 'conf/conf.rb'
require_relative 'lib/aux.rb'
require 'yaml'
require 'open-uri'


class Mirage
  
  def initialize
    @cnt = 0
  end

  def run
    loop do
      process_one_link
    end
  end
  
  def process_one_page page, org_link
    Util.log "Getting a page #{page_port}"
    if !page.nil?
      urls = page.parse_page
      return if urls.nil?
      urls.each do |url|
        save_url page, url
      end
      begin
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

  def save_url page, org_url
    #determine if valid
    url = Link.full_url(page.url, org_url)
    Util.log "Checking #{url}"
    unless valid_url?(url)
      Util.log "Non valid url, #{url}"
      return
    end
    #determine if intersted. (domain, regex, and similarity)
    unless Rule.ok?(url)
      #return
    end

    if Link.exists? url
      Util.log("Duplicated url.")
      return
    end
  
    Util.log "Saved #{url}"
    l=Link.new
    l.url = url 
    l.depth = page.link.depth + 1 rescue nil
    l.state = LINK_STATE_UNPROCESSED
    l.save
  end

  def process_one_link
    link = get_a_link
    #if link is accquired successful
    unless link.nil?
      link.state = LINK_STATE_PROCESSED
      link.save
      #processing page now
      page = dl link
      #if page is dl'ed successful
      process_one_page page, link.url
    else
      Util.log "no more job, sleep for a while"
      sleep 0.01
    end
  end

  def dl link, remain_times = 2
    return unless link.is_a? Link
    page = Page.new
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
          page.url     = link.url
          page.content = f.read
          page.charset = f.charset
          page.mime    = f.content_type
          page.code    = f.status[0].to_i
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
    page
  end

  def get_a_link
    @new_links = Link.where(:state => LINK_STATE_UNPROCESSED).limit 1
  end
end

m=Mirage.new

