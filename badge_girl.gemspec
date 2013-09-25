$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'badge_girl/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'badge_girl'
  s.version     = BadgeGirl::VERSION
  s.authors     = ['Hamed Asghari']
  s.email       = %w(hasghari@gmail.com)
  s.homepage    = 'http://github.com/hasghari/badge_girl'
  s.summary     = 'Summary of BadgeGirl.'
  s.description = 'Description of BadgeGirl.'

  s.files = Dir['{app,config,db,lib}/**/*'] + %w(MIT-LICENSE Rakefile README.rdoc)
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'ambry', '~> 0.3.0'
  s.add_dependency 'nilify_blanks'

  s.add_development_dependency 'rails', '>= 3.2.13'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'database_cleaner'
end
