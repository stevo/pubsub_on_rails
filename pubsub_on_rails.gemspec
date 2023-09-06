# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'pub_sub/version'

Gem::Specification.new do |s|
  s.name          = 'pubsub_on_rails'
  s.version       = PubSub::VERSION
  s.authors       = ['Stevo']
  s.email         = ['b.kosmowski@selleo.com']
  s.homepage      = 'https://github.com/Selleo/pubsub_on_rails'
  s.licenses      = ['MIT']
  s.summary       = 'Opinionated publish-subscribe pattern for ruby and rails'
  s.description   = 'Opinionated publish-subscribe pattern for ruby and rails'

  s.files         = Dir.glob('{bin/*,lib/**/*,[A-Z]*}')
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.add_dependency 'dry-struct'
  s.add_dependency 'rails_event_store'
  s.add_dependency 'ruby_event_store-rspec'
end
