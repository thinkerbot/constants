require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

# tasks
desc 'Default: Run tests.'
task :default => :test

desc 'Run tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = File.join('test', ENV['subset'] || '', ENV['pattern'] || '**/*_test.rb')
  t.verbose = true
end

#
# Gem specification
#
spec = Gem::Specification.new do |s|
	s.name = "constants"
	s.version = "0.1.0"
	s.author = "Simon Chiang"
	s.email = "simon.chiang@uchsc.edu"
	s.homepage = "http://rubyforge.org/projects/bioactive/"
	s.platform = Gem::Platform::RUBY
	s.summary = "Libraries of constants.  Includes libraries for elements, molecules, particles, and physical constants."
  s.rubyforge_project = "bioactive"
	s.files = File.read("Manifest.txt").strip.split(/\s*\r?\n\s*/).select {|file| file !~ /#/ && File.file?(file) }
	s.require_path = "lib"
	s.test_file = "test/constants_test_suite.rb"
	
	s.has_rdoc = true
	s.extra_rdoc_files = ["README", 'MIT-LICENSE']
  s.add_dependency("ruby-units", ">=1.1.3")
end

Rake::GemPackageTask.new(spec) do |pkg|
	pkg.need_tar = true
end

desc "Print the current gemspec files"
task :gem_files do
  require 'pp'
  pp spec.files
end

#
# admin tasks
#

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'molecule' 
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include(["README", 'MIT-LICENSE'])
  rdoc.rdoc_files.include(spec.files.select {|file| file =~ /^lib/})
end

desc "Publish RDoc to RubyForge"
task :publish_rdoc => [:rdoc] do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  
  rsync_args = "-v -c -r"
  remote_dir = "/var/www/gforge-projects/bioactive/molecule"
  local_dir = "rdoc"
 
  sh %{rsync #{rsync_args} #{local_dir}/ #{host}:#{remote_dir}}
end

#
# constants tasks
#

desc "Regenerate physical constants data"
task :generate_physical_constants do
  require 'open-uri'
  
  nist_url = "http://www.physics.nist.gov/cuu/Constants/Table/allascii.txt"
  nist_data = open(nist_url)
  
  puts "# Constants from: #{nist_url}"
  puts "# Date: #{Time.now.to_s}"
  
  split_regexp = /^(.+?\s\s)(\d[\de\-\s\.]*?\s\s\s*)(\d[\de\-\s\.]*?\s\s\s*)(.*)$/
  split_regexp_str = nil
  constants = []
  declarations = []
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
    declarations << [constant, name.strip, value.gsub(/\s/, ""), uncertainty.gsub(/\s/, "").gsub("(exact)", "0"), unit.strip]
  end
  
  max = constants.inject(0) {|max, c| c.length > max ? c.length : max}
  declarations.each do |declaration|
    puts %Q{%-#{max}s = Physical.new("%s", "%s", "%s", "%s")} % declaration
  end
end
