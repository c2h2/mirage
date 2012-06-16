class Youtube 
  include Mongoid::Document
  include Mongoid::Timestamps
  field :yid, :type => String
  field :state, :type => Integer

  def self.get_yid url
    regex = /youtube.com.*(?:\/|v=)([^&$]+)/
    res = url.match(regex)
    if res.nil?
      return nil
    end
    res[1]
  end

  def self.valid_video? url
    regex =  /^http:\/\/(?:www\.)?youtube.com\/watch\?v=\w+(&\S*)?$/
    !url.match(regex).nil?
  end


end
