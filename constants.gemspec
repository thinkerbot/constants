Gem::Specification.new do |s|
	s.name = "constants"
	s.version = "0.1.0"
	s.author = "Simon Chiang"
	s.email = "simon.a.chiang@gmail.com"
	s.homepage = "http://bioactive.rubyforge.org/constants/"
	s.platform = Gem::Platform::RUBY
	s.summary = "Libraries of constants.  Includes libraries for elements, particles, and physical constants."
  s.rubyforge_project = "bioactive"
  s.require_path = "lib"
	s.test_file = "test/constants_test_suite.rb"
	s.has_rdoc = true
  s.add_dependency("ruby-units", ">=1.1.3")
  
	s.extra_rdoc_files = %w{
    README
    MIT-LICENSE
  }
  
	s.files = %w{
    MIT-LICENSE
    Rakefile
    README
    lib/constants/constant.rb
    lib/constants/constant_library.rb
    lib/constants/libraries/element.rb
    lib/constants/libraries/particle.rb
    lib/constants/libraries/physical.rb
    lib/constants/library.rb
    lib/constants/stash.rb
    lib/constants/uncertainty.rb
    lib/constants.rb
    test/constants/constant_library_test.rb
    test/constants/constant_test.rb
    test/constants/libraries/element_test.rb
    test/constants/libraries/particle_test.rb
    test/constants/libraries/physical_test.rb
    test/constants/library_test.rb
    test/constants/stash_test.rb
    test/constants_test_helper.rb
    test/constants_test_suite.rb
    test/readme_doc_test.rb
	}
end
