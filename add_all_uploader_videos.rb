require 'youtube_it'
require 'pp'
require_relative 'conf/dev_key.rb'


class Util
  def self.log str
    puts str
  end
end

class Youtube
  def initialize
    @client = YouTubeIt::Client.new(:dev_key => DEV_KEY)
    @per_page = 50 # this seems to be maxium
  end


  def query_uploader user, page=0
    @client.videos_by(:user => user, :per_page => @per_page, :page => page)

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

yt=Youtube.new
#res = yt.query_uploader 'HuskyStarcraft', 0
#pp res
#videos = yt.uploader_all_videos "HuskyStarcraft"
videos = yt.uploader_all_videos "GoogleDevelopers"
videos.each do |v|
  puts "#{v.author.name}|#{v.title}|#{v.unique_id}"

end


