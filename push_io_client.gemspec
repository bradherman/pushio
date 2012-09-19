# -*- encoding: utf-8 -*-
require File.expand_path('../lib/push_io/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Push IO LLC", "Sean McKibben"]
  gem.email         = ["sean@push.io"]
  gem.description   = %q{Ruby client library to send push notifications via the Push IO API. See: http://push.io for more information and to set up your account.}
  gem.summary       = %q{This gem enables developers to easily create new notifications and send them via the Push IO API from Ruby apps.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "push_io_client"
  gem.require_paths = ["lib"]
  gem.version       = PushIoClient::VERSION

  gem.add_dependency("httpclient", '>= 2.2.7')
  gem.add_dependency("multi_json", '>= 1.3.0')

  gem.add_development_dependency("rspec", '>= 2.11.0')
end
