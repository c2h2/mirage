class Youtube 
  include Mongoid::Document
  include Mongoid::Timestamps
  field :yid, :type => String
  field :state, :type => Integer




end
