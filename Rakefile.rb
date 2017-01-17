$LOAD_PATH.unshift(File.expand_path(File.join('..', 'lib'), __FILE__))

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
