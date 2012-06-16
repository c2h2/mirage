class Ua
  include Mongoid::Document
  field :ua, :type => String
  field :weight, :type => Float
end
