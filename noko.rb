require 'nokogiri'


noko_doc = Nokogiri::HTML(File.read(ARGV[0]))
noko_doc.css('a').each do |a|

puts a
end

puts noko_doc.title.strip.split("\n")[0] 
