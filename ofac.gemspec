# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ofac}
  s.version = "1.1.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kevin Tyll"]
  s.date = %q{2010-02-05}
  s.description = %q{Attempts to find a hit on the Office of Foreign Assets Control's Specially Designated Nationals list.}
  s.email = %q{kevintyll@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "History.txt",
     "LICENSE",
     "PostInstall.txt",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "generators/ofac_migration/.DS_Store",
     "generators/ofac_migration/ofac_migration_generator.rb",
     "generators/ofac_migration/templates/.DS_Store",
     "generators/ofac_migration/templates/migration.rb",
     "lib/ofac.rb",
     "lib/ofac/models/ofac.rb",
     "lib/ofac/models/ofac_sdn.rb",
     "lib/ofac/models/ofac_sdn_loader.rb",
     "lib/ofac/ofac_match.rb",
     "lib/ofac/ruby_string_extensions.rb",
     "lib/tasks/ofac.rake",
     "nbproject/project.properties",
     "nbproject/project.xml",
     "ofac.gemspec",
     "pkg/ofac-0.1.0.gem",
     "pkg/ofac-1.0.0.gem",
     "rdoc/classes/Ofac.html",
     "rdoc/classes/OfacMatch.html",
     "rdoc/classes/OfacSdn.html",
     "rdoc/classes/OfacSdnLoader.html",
     "rdoc/classes/String.html",
     "rdoc/created.rid",
     "rdoc/files/README_rdoc.html",
     "rdoc/files/lib/ofac/models/ofac_rb.html",
     "rdoc/files/lib/ofac/models/ofac_sdn_loader_rb.html",
     "rdoc/files/lib/ofac/models/ofac_sdn_rb.html",
     "rdoc/files/lib/ofac/ofac_match_rb.html",
     "rdoc/files/lib/ofac/ruby_string_extensions_rb.html",
     "rdoc/files/lib/ofac_rb.html",
     "rdoc/fr_class_index.html",
     "rdoc/fr_file_index.html",
     "rdoc/fr_method_index.html",
     "rdoc/index.html",
     "rdoc/rdoc-style.css",
     "test/files/test_address_data_load.pip",
     "test/files/test_alt_data_load.pip",
     "test/files/test_sdn_data_load.pip",
     "test/files/valid_flattened_file.csv",
     "test/mocks/test/ofac_sdn_loader.rb",
     "test/ofac_sdn_loader_test.rb",
     "test/ofac_test.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/kevintyll/ofac}
  s.post_install_message = %q{For more information on ofac, see http://kevintyll.github.com/ofac/

* To create the necessary db migration, from the command line, run:
    script/generate ofac_migration
* Require the gem in your environment.rb file in the Rails::Initializer block:
    config.gem 'kevintyll-ofac', :lib => 'ofac'
* To load your table with the current OFAC data, from the command line, run:
    rake ofac:update_data

    * The OFAC data is not updated with any regularity, but you can sign up for email notifications when the data changes at
        http://www.treas.gov/offices/enforcement/ofac/sdn/index.shtml.}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Attempts to find a hit on the Office of Foreign Assets Control's Specially Designated Nationals list.}
  s.test_files = [
    "test/mocks/test/ofac_sdn_loader.rb",
     "test/ofac_sdn_loader_test.rb",
     "test/ofac_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

