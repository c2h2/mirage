class Page
  include Mongoid::Document
  include Mongoid::Timestamps
  field :worker, :type => String
  field :code, :type => Integer
  field :url, :type => String
  field :fn, :type => String
  field :content, :type => String
  field :charset, :type => String
  field :title, :type => String
  field :mime, :type => String
  field :etag, :type => String
  field :resp_ms, :type => Integer
  field :length, :type => Integer
  field :state, :type => Integer
  field :hash, :type => String
  field :lm_at, :type => DateTime
  field :exp_at, :type => DateTime


  belongs_to :link
  
  def get_port
    p=PagePort.new
    p.worker    = self.worker
    p.code      = self.code
    p.url       = self.url
    p.fn        = self.fn
    p.content   = self.content
    p.charset   = self.charset
    p.title     = self.title
    p.mime      = self.mime
    p.etag      = self.etag
    p.resp_ms   = self.resp_ms
    p.length    = self.length
    p.state     = self.state
    p.hash      = self.hash
    p.lm_at     = self.lm_at
    p.exp_at    = self.exp_at
    p.created_at = self.created_at
    p.updated_at = self.updated_at
    p
  end

  def parse_page
    if self.content.nil?
      return nil
    end
    @noko_doc = Nokogiri::HTML(self.content)
    @found_links = @noko_doc.css('a').map{|l| l['href'].to_s}
    Util.log "Found #{@found_links.count} links"
    @found_links
  end
end

class PagePort
  attr_accessor :worker, :code, :url, :fn, :content, :charset, :title, :mime, :etag, :resp_ms, :length, :state, :hash, :lm_at, :exp_at, :created_at, :updated_at


  def get_page
    p=Page.new
    p.worker    = self.worker
    p.code      = self.code
    p.url       = self.url
    p.fn        = self.fn
    p.content   = self.content
    p.charset   = self.charset
    p.title     = self.title
    p.mime      = self.mime
    p.etag      = self.etag
    p.resp_ms   = self.resp_ms
    p.length    = self.length
    p.state     = self.state
    p.hash      = self.hash
    p.lm_at     = self.lm_at
    p.exp_at    = self.exp_at
    p.created_at = self.created_at
    p.updated_at = self.updated_at  
    p
  end
end
