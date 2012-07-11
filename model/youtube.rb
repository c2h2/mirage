class Youtube 
  include Mongoid::Document
  include Mongoid::Timestamps
  field :yid, :type => String
  field :state, :type => Integer
  field :thumb, :type => String
  field :title, :type => String
  field :uploader, :type => String
  field :info_saved, :type => Boolean, :default => false
  field :downloaded, :type => Boolean, :default => false
  field :if_download, :type => Boolean, :default => false
  field :fn, :type => String
  field :sha1, :type => String
  
  has_one :page

  index({yid: 1}, {unique: true})

  def self.get_yid url
    regex = /youtube.com.*(?:\/|v=)([^&$]+)/
    res = url.match(regex)
    if res.nil?
      return nil
    end
    res[1]
  end

  def self.get_uploader
    noko = Nokogiri::HTML(self.page.content)
    noko.css('#watch-uploader-info a').first.content
  end

  def self.exists? yid
    self.where(:yid => yid).count >= 1 
  end

  def self.valid_video? url
    regex =  /^http:\/\/(?:www\.)?youtube.com\/watch\?v=\w+(&\S*)?$/
    !url.match(regex).nil?
  end

end

class You2

  def initialize
    @client = YouTubeIt::Client.new #(:dev_key => DEV_KEY)
    @per_page = 50 # this seems to be maxium
  end

  def query_uploader user, page=0
    res = @client.videos_by(:user => user, :per_page => @per_page, :page => page)
    res
  end

  def uploader_all_videos user
    results = []
    videos = []
    results[0] = query_uploader(user)
    total_videos = results[0].total_result_count
    if total_videos > @per_page
      total_pages = total_videos / @per_page
      total_pages.times do |i|
        Util.log "next page #{i}"
        next if i==0 # we have already got results for page 0
        results[i]=self.query_uploader(user, i)
      end

    else
      #sucks not many pages
    end

    results.each do |res|
      videos << res.videos
    end
    videos.flatten
  end


end
