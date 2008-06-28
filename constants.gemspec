Gem::Specification.new do |s|
	s.name = "constants"
	s.version = "0.1.0"
	s.author = "Simon Chiang"
	s.email = "simon.a.chiang@gmail.com"
	s.homepage = "http://bioactive.rubyforge.org/constants/"
	s.platform = Gem::Platform::RUBY
	s.summary = "Libraries of constants.  Includes libraries for elements, particles, and physical constants."
  s.rubyforge_project = "bioactive"
	s.files = File.read("Manifest.txt").strip.split(/\s*\r?\n\s*/).select {|file| file !~ /#/ && File.file?(file) }
	s.require_path = "lib"
	s.test_file = "test/constants_test_suite.rb"
	
	s.has_rdoc = true
	s.extra_rdoc_files = ["README", 'MIT-LICENSE']
  s.add_dependency("ruby-units", ">=1.1.3")
end
