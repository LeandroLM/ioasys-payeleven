$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ioasys_payleven/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ioasys_payleven"
  s.version     = IoasysPayleven::VERSION
  s.authors     = ["Lucas Rizel"]
  s.email       = ["lucasrizel@ioasys.com.br"]
  s.homepage    = "http://www.ioasys.com.br/"
  s.summary     = "Integrate your API with a payleven API."
  s.description = "Handles in an easy way ruby with payleven API."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_runtime_dependency "rest-client"
  #s.add_dependency "rubygems"
  #s.add_dependency "json"
  #s.add_dependency "activesupport"

  s.add_development_dependency "sqlite3"
end
