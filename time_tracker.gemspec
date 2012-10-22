# -*- encoding: utf-8 -*-
require File.expand_path('../lib/time_tracker/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Thorben Schröder"]
  gem.email         = ["info@thorbenschroeder.de"]
  gem.description   = %q{A CLI time tracking tool}
  gem.summary       = %q{A CLI time tracking tool}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "time_tracker"
  gem.require_paths = ["lib"]
  gem.version       = TimeTracker::VERSION
end