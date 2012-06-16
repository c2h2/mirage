class Conf
  include Mongoid::Document
  field :key, :type => String
  field :value, :type => String

  def g key
    where(key: key).first
  end

  def s key, value
    item = where(key: key).first
    if item.nil?
      item = Conf.new
    end
    item.key = key
    item.value = value
    item.save
  end
end
