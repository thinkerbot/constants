$: << File.dirname(__FILE__) + "/../../../../external/lib"
$: << File.dirname(__FILE__) + "/../lib"

require 'pp'

File.open("nist_physical_constants.txt") do |source|
  File.open("physical.txt", "w") do |target|
    source.each_line do |line|
      next if line =~ /^(\s|-)/
      
      name, value, uncertainty, unit = line.split(/\s\s\s*/).collect {|s| s.strip}
      target.puts %Q{    # = Physical.new("#{name}", "#{value}", "#{uncertainty}", "#{unit}")}
    end
  end
end
