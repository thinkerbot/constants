$: << File.dirname(__FILE__) + "/../../../../external/lib"
$: << File.dirname(__FILE__) + "/../lib"

require 'external'
require 'stringio'
require 'constants/element'
require 'ostruct'
require 'pp'

ea = ExtArc.open("nist.txt")
ea.io.pos = 0
ea.io.each_line do |line|
  break if line =~ /^Atomic Number/
end

span_begin = ea.io.pos
ea.reindex_by_regexp /^Atomic Number.*?\r?\n\r?\n/m, :span => span_begin..-1

elements = {}
attributes = {}
ea.each do |entry|
  hash = {}

  str = StringIO.new(entry)
  str.each_line do |line|
    key, value = line.split(/=/).collect {|s| s.strip}
    hash[key] = value
  end
  
  next if hash['Isotopic Composition'].empty?
  
  attributes[hash['Atomic Number'].to_i] ||= [hash['Atomic Number'], hash['Atomic Symbol'], hash['Standard Atomic Weight']]
  (elements[hash['Atomic Number'].to_i] ||= []) << hash
end

entries = []
elements.each_pair do |number, isotopes|
  element = Constants::Element[number]
  name = element == nil ? nil : element.name
  number, symbol, std_weight = attributes[number]
  
  lines = isotopes.sort_by do |isotope| 
    isotope['Mass Number']
  end.collect do |isotope|
    unless isotope['Atomic Symbol'] == symbol
      pp isotope 
    end
    
    "#{isotope['Mass Number']}:#{isotope['Relative Atomic Mass']}:#{isotope['Isotopic Composition']}"
  end.compact

  entries << [symbol, %Q{    #{symbol} = Element.new("#{symbol}", "#{name}", #{number}, "#{lines.join(';')}", "#{std_weight}")}]
end

entries = entries.sort_by {|symbol, str| symbol}.collect {|symbol, str| str}
File.open('element.txt', 'w') do |file|
  file << entries.join("\n")
end