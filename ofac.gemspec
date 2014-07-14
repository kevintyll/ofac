$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ofac/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "ofac"
  s.version = Ofac::VERSION
  s.authors = ["Kevin Tyll"]
  s.email = "kevintyll@gmail.com"
  s.homepage = "https://github.com/kevintyll/ofac"
  s.summary = "Attempts to find a hit on the Office of Foreign Assets Control's Specially Designated Nationals list."
  s.description = "Attempts to find a hit on the Office of Foreign Assets Control's Specially Designated Nationals list."
  s.post_install_message = File.readlines("PostInstall.txt").join("")

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2"

  s.add_development_dependency 'sqlite3'

  s.license = 'MIT'

end
