Gem::Specification.new do |s|
  s.name = "constants"
  s.version = "0.1.1"
  s.author = "Simon Chiang"
  s.email = "simon.a.chiang@gmail.com"
  s.homepage = "http://bioactive.rubyforge.org/constants/"
  s.platform = Gem::Platform::RUBY
  s.summary = "Libraries of constants.  Includes libraries for elements, particles, and physical constants."
  s.rubyforge_project = "bioactive"
  s.require_path = "lib"
  s.has_rdoc = true
  s.add_dependency("ruby-units", ">=1.1.3")
  s.add_development_dependency("tap", ">=0.10.8")
  
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
  }
end
