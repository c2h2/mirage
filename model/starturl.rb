class Starturl
  include Mongoid::Document
  field :url, :type => String
  field :weight, :type => Float
end
