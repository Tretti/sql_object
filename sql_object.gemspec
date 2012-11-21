$:.push File.expand_path("../lib", __FILE__)

require "sql_object/version"

Gem::Specification.new do |s|
  s.name        = "sql_object"
  s.version     = SqlObject::VERSION
  s.authors     = ["Bjorn Nilsson"]
  s.email       = ["bjorn.nilsson@tretti.se"]
  s.homepage    = ""
  s.summary     = "SQL templating/versioning"
  s.description = "SQL templating/versioning"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.0"

end
