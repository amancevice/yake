# frozen_string_literal: true

require_relative "lib/yake/version"

Gem::Specification.new do |spec|
  spec.name                  = "yake"
  spec.version               = Yake::VERSION
  spec.authors               = ["Alexander Mancevice"]
  spec.email                 = ["alexander.mancevice@hey.com"]
  spec.summary               = "Rake-like DSL for declaring AWS Lambda function handlers"
  spec.homepage              = "https://github.com/amancevice/yake"
  spec.license               = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = spec.homepage
  spec.metadata["changelog_uri"]     = "#{ spec.homepage }/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
