require_relative 'lib/aspen/version'

Gem::Specification.new do |spec|
  spec.name          = "aspen"
  spec.version       = Aspen::VERSION
  spec.authors       = ["Matt Cloyd"]
  spec.email         = ["cloyd.matt@gmail.com"]

  spec.summary       = %q{
    Aspen turns simple text into graph data, compiling it into Cypher for Neo4j graph databases.
  }
  spec.description   = %q{
    Aspen is a simple markup language that renders into Cypher. Write narrative data,
    mark it up, and compile to Cypher.
  }
  spec.homepage      = "https://github.com/beechnut/aspen"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  # spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "pry"

  spec.add_dependency "dry-cli",        "~> 0.5"
  spec.add_dependency "dry-container",  "~> 0.7"
  spec.add_dependency "dry-monads",     "~> 1.0"
  spec.add_dependency "dry-validation", "~> 1.4"
  spec.add_dependency "activesupport",  "~> 6.0"
end
