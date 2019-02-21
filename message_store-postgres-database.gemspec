# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'evt-message_store-postgres-database'
  s.version = '1.1.0.0'
  s.summary = 'Message store PostgreSQL database definition'
  s.description = ' '

  s.authors = ['The Eventide Project']
  s.email = 'opensource@eventide-project.org'
  s.homepage = 'https://github.com/eventide-project/message-store-postgres-database'
  s.licenses = ['MIT']

  s.files = Dir.glob('{database}/**/*')
  s.executables = Dir.glob('scripts/evt-*').map(&File.method(:basename))
  s.bindir = 'scripts'
end
