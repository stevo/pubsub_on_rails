# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'pubsub_on_rails/version'

Gem::Specification.new do |s|
  s.name          = 'pubsub_on_rails'
  s.version       = PubsubOnRails::VERSION
  s.authors       = ['Stevo']
  s.email         = ['b.kosmowski@selleo.com']
  s.homepage      = 'https://github.com/stevo/pubsub_on_rails'
  s.licenses      = ['MIT']
  s.summary       = '[summary]'
  s.description   = '[description]'

  s.files         = Dir.glob('{bin/*,lib/**/*,[A-Z]*}')
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
end
