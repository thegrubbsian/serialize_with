# -*- encoding: utf-8 -*-
require File.expand_path("../lib/serialize_with/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["JC Grubbs", "Kori Roys"]
  gem.email         = ["jc@devmynd.com", "kori@devmynd.com"]
  gem.description   = %q{An add-on for ActiveRecord and Mongoid which allows serialization options to be stored on a model.}
  gem.summary       = %q{An add-on for ActiveRecord and Mongoid which allows serialization options to be stored on a model.}
  gem.homepage      = "https://github.com/thegrubbsian/serialize_with"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "serialize_with"
  gem.require_paths = ["lib"]
  gem.version       = SerializeWith::VERSION

  gem.add_dependency "activesupport", "~>3.0"

  gem.add_development_dependency "activerecord", "~>3.0"
  gem.add_development_dependency "mongoid", "~>3.0"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "sqlite3"
end
