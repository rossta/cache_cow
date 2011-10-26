# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cache_cow/version"

Gem::Specification.new do |s|
  s.name        = "cache_cow"
  s.version     = CacheCow::VERSION
  s.authors     = ["Ross Kaffenberger"]
  s.email       = ["rosskaff@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "cache_cow"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 3.0"

  s.add_development_dependency "dalli"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency 'steak'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'ammeter'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency "sqlite3"
end
