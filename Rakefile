require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'yaml'

# tasks
desc 'Default: Run tests.'
task :default => :test

desc 'Run tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = File.join('test', ENV['subset'] || '', ENV['pattern'] || '**/*_test.rb')
  t.warning = true
  t.verbose = true
end

#
# admin tasks
#

def gemspec
  data = File.read('constants.gemspec')
  spec = nil
  Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
  spec
end

Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.need_tar = true
end

task :print_manifest do
  # collect files from the gemspec, labeling 
  # with true or false corresponding to the
  # file existing or not
  files = gemspec.files.inject({}) do |files, file|
    files[File.expand_path(file)] = [File.exists?(file), file]
    files
  end
  
  # gather non-rdoc/pkg files for the project
  # and add to the files list if they are not
  # included already (marking by the absence
  # of a label)
  Dir.glob("**/*").each do |file|
    next if file =~ /^(rdoc|pkg)/ || File.directory?(file)
    
    path = File.expand_path(file)
    files[path] = ["", file] unless files.has_key?(path)
  end
  
  # sort and output the results
  files.values.sort_by {|exists, file| file }.each do |entry| 
    puts "%-5s : %s" % entry
  end
end

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'constants' 
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include(["README", 'MIT-LICENSE'])
  rdoc.rdoc_files.include(gemspec.files.select {|file| file =~ /^lib/})
end

desc "Publish RDoc to RubyForge"
task :publish_rdoc => [:rdoc] do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  
  rsync_args = "-v -c -r"
  remote_dir = "/var/www/gforge-projects/bioactive/constants"
  local_dir = "rdoc"
 
  sh %{rsync #{rsync_args} #{local_dir}/ #{host}:#{remote_dir}}
end

#
# constants tasks
#

desc "Regenerate physical constants and relationship data"
task :generate_constants do
  require 'open-uri'

  nist_url = "http://www.physics.nist.gov/cuu/Constants/Table/allascii.txt"
  nist_data = open(nist_url)
  
  split_regexp = /^(.+?\s\s)(\d[\de\-\s\.]*?\s\s\s*)(\d[\de\-\s\.]*?\s\s\s*)(.*)$/
  split_regexp_str = nil
  
  constants = []
  declarations = []
  units = []

  nist_data.each_line do |line|
    next if line =~ /^(\s|-)/
    
    unless line =~ split_regexp
      raise "could not match line:\n#{line}\nwith: #{split_regexp_str}" 
    end
    
    if split_regexp_str == nil
      split_regexp_str = "^(.{#{$1.length}})(.{#{$2.length}})(.{#{$3.length}})(.*)$"
      split_regexp = Regexp.new(split_regexp_str)
      redo
    end
    
    name = $1
    value = $2
    uncertainty = $3
    unit = $4
    constant = name.split(/[\s\-]/).collect do |word| 
      word = word.gsub(/\./, "")
      word = word.gsub("/", "_")
      
      word =~ /^[A-z\d]+$/ ? word.upcase : nil
    end.compact.join("_")
    
    if constants.include?(constant)
      raise "constant name conflict: #{constant}" 
    end
    
    constants << constant
    type = (constant =~ /_RELATIONSHIP$/ ? units : declarations) 
    type << [constant, name.strip, value.gsub(/\s/, ""), uncertainty.gsub(/\s/, "").gsub("(exact)", "0"), unit.strip]
  end
  
  puts "# Constants from: #{nist_url}"
  puts "# Date: #{Time.now.to_s}"
  
  max = declarations.inject(0) {|max, c| c.first.length > max ? c.first.length : max}
  declarations.each do |declaration|
    puts %Q{%-#{max}s = Physical.new("%s", "%s", "%s", "%s")} % declaration
  end
  
  puts
  puts "# Relationships from: #{nist_url}"
  puts "# Date: #{Time.now.to_s}"
  
  require 'ruby-units'
  base_units = Unit.class_eval('@@BASE_UNITS').collect {|u| u[1..-2] }
  unit_map = Unit.class_eval('@@UNIT_MAP')
  units = units.collect do |constant, name, value, uncertainty, unit|
    
    # parse the relationship units
    unit_name, relation_name = name.strip.chomp('relationship').split('-', 2).collect do |str| 
      str.strip!
      case str
      when 'atomic mass unit' then 'amu'
      else str.gsub(/\s/, "-")
      end
    end
    
    # format constants to sort in the correct declaration order
    constant = constant.chomp('_RELATIONSHIP')
    [constant, unit_name, relation_name, value, unit, uncertainty]
  end
  
  max = units.inject(0) {|max, c| c.first.length > max ? c.first.length : max}
  units.each do |declaration|
    puts %Q{%-#{max}s = ['%s', '%s', '%s', '%s', '%s']} % declaration
  end
end

# desc "Regenerate elements data"
# task :generate_elements do
#   
# end
