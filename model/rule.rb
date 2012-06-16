class Rule
  include Mongoid::Document
  field :domain, :type => String
  field :detail, :type => String
  field :allow, :type => Boolean


  def self.ok? url
    the_domain = self.domain url
    rules =  Rule.where(:domain => the_domain)
    if rules.size == 0
      return false
    else 
      rules.each do |rule|
        regexp = Regexp.new(rule.detail)
=begin
        if rule.allow        
          #white filter
          if url =~ rule.detail
            return true
          end
        else
          #black filter
          if url =~ rule.detail
            return false
          end
        end
=end
        #this logic is = above logic
        unless (url =~ regexp).nil?
          return rule.allow
        end
      end 

    end 
  end

  def self.domain url
    domain = nil
    begin
      domain=URI.parse(url).host 
    rescue
    end
    domain
  end
end
