require 'logger'
require 'digest'

LOG = Logger.new(STDOUT)

### AUX classes ###
class Stopwatch
  def initialize
    start
  end

  def start
    @t0 = Time.now
  end

  def end
    @t1 = Time.now
    @t1 - @t0
  end

  def self.ts
    Time.now.to_i.to_s
  end

  def self.ts2
    t=Time.new.to_i.to_s
    [t.slice(0..6), t.slice(7..-1)]
  end

end

class Util
  def self.hexsha512 str
    Digest::SHA512::hexdigest str
  end

  def self.sha512 str
    Digest::SHA512::digest str
  end

  def self.hexsha384 str
    Digest::SHA384::hexdigest str
  end

  def self.sha384 str
    Digest::SHA384::digest str
  end
  
  def self.hexmd5 str
    Digest::MD5::hexdigest str
  end
 
  def self.md5 str
    Disgest::MD5::digest str
  end

  def self.log str, error_level=1
    str = str.to_s
    @@counter ||=0
    str="" if str.nil?
    str = Time.now.to_s + "|" + (@@counter+=1).to_s+ "|" + str
    if error_level > 1
      LOG.warn str
    else
      LOG.info str
    end
  end

  def self.exit
    self.log "exiting..."
    exit 0
  end
end

