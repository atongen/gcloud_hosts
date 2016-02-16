# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gcloud_hosts/version'

Gem::Specification.new do |spec|
  spec.name          = "gcloud_hosts"
  spec.version       = GcloudHosts::VERSION
  spec.authors       = ["Andrew Tongen"]
  spec.email         = ["atongen@gmail.com"]

  spec.summary       = %q{Update your hosts file based on gcloud compute instances}
  spec.description   = %q{Update your hosts file based on gcloud compute instances}
  spec.homepage      = "https://github.com/atongen/gcloud_hosts"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
