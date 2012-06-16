class Link
  include Mongoid::Document
  include Mongoid::Timestamps
  field :url, :type => String
  field :rank, :type => Float
  field :lv_at, :type => DateTime
  field :state, :type => Integer
  field :depth, :type => Integer


  has_many :pages

  
  def self.exists? url
    ! Link.where(:url => url).first.nil?
  end

  def self.full_url old_url, url
    begin
      (URI.parse(old_url)+url).to_s
    rescue
      " "
    end
  end

  

end
