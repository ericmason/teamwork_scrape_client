# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'teamwork_scrape_client/version'

Gem::Specification.new do |spec|
  spec.name          = "teamwork_scrape_client"
  spec.version       = TeamworkScrapeClient::VERSION
  spec.authors       = ["Eric Mason"]
  spec.email         = ["eric@equisolve.com"]

  spec.summary       = %q{Unofficial Teamwork.com scraping client to supplement the official API}
  spec.description   = %q{Unofficial Teamwork.com scraping client to supplement the official API. Provides the ability to copy projects.}
  spec.homepage      = "https://github.com/ericmason/equisolve-teamwork_scrape_client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency 'mechanize', '~> 2.7'
end
