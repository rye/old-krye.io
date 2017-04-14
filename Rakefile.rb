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

desc "Generates ctags for the project."
task :tag do

	require 'site/logger'

	IO.popen(["ctags", "-eR", "--languages=ruby", "--verbose=yes", "--tag-relative=yes", "--exclude=.git", "--exclude=log", "."], "r") do |process|
		process.readlines.each do |line|
			Site::Logger.info 'ctags' do
				line.chomp
			end
		end
	end

end
