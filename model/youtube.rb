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
    self.where(:yid => yid).limit(1).length >= 1 
  end

  def self.valid_video? url
    regex =  /^http:\/\/(?:www\.)?youtube.com\/watch\?v=\w+(&\S*)?$/
    !url.match(regex).nil?
  end


end
