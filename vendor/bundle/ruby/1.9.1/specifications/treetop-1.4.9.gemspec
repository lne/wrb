# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "treetop"
  s.version = "1.4.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Sobo"]
  s.autorequire = "treetop"
  s.date = "2010-11-15"
  s.email = "nathansobo@gmail.com"
  s.executables = ["tt"]
  s.files = ["bin/tt"]
  s.homepage = "http://functionalform.blogspot.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "A Ruby-based text parsing and interpretation DSL"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<polyglot>, [">= 0.3.1"])
    else
      s.add_dependency(%q<polyglot>, [">= 0.3.1"])
    end
  else
    s.add_dependency(%q<polyglot>, [">= 0.3.1"])
  end
end
