source 'https://rubygems.org'

# Server dependencies
gem 'thin', '~> 1.7'
gem 'sinatra', '~> 1.4'
gem 'sinatra-advanced-routes', '~> 0.5'

# Redis dependency
gem 'redis', '~> 3.2'

# Template-related dependencies
gem 'sass', '~> 3.4'
gem 'coffee-script', '~> 2.4'
gem 'github-markup', '~> 1.6'

# Internal dependencies related to the file system
gem 'listen', '~> 3.1'
gem 'mime-types', '~> 3.1'

# Colored output
gem 'colorize', '~> 0.8'

group :development, :test do
	# We should always have Rake available, but explicitly specify
	# dependency just in case.
	gem 'rake', '~> 12.0'

	# Spec-related dependencies
	gem 'rspec', '~> 3.5'
	gem 'rubocop', '~> 0.49'

	# Rollout dependencies
	gem 'scientist', '~> 1.0'

	# Code Climate coverage reporting
	gem 'simplecov', '~> 0.13'
	gem 'codeclimate-test-reporter', '~> 1.0'
end

group :development do
	# Automated development-environment testing dependencies
	gem 'guard', '~> 2.14'
	gem 'guard-rspec', '~> 4.7'
	gem 'guard-rubocop', '~> 1.3'

	# Inspection dependencies
	gem 'pry', '~> 0.10'
end
