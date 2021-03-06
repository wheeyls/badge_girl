ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rails/test_help'
require 'badge_girl'
require 'database_cleaner'

Rails.backtrace_cleaner.remove_silencers!

ActiveRecord::Migrator.migrate File.expand_path('../dummy/db/migrate/', __FILE__)

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  DatabaseCleaner.strategy = :transaction

  config.before { DatabaseCleaner.start }
  config.after  { DatabaseCleaner.clean }

  # remove badges for specs
  config.before do
    BadgeGirl::Badge.all.each(&:delete)
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
