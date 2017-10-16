$LOAD_PATH.unshift(File.expand_path(File.join('..', 'lib'), __FILE__))

desc "Runs spec and submits CodeClimate test coverage."
task :ci do
	[:spec, :codeclimate_test_report].each do |task|
		Rake::Task[task].invoke
	end
end

task :codeclimate_test_report do
	system("bundle exec codeclimate-test-reporter")
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
