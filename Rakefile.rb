$LOAD_PATH.unshift(File.expand_path(File.join('..', 'lib'), __FILE__))

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :tag do
	IO.popen("ctags -eR --languages=ruby --verbose=yes --tag-relative=yes --exclude=.git --exclude=log .", "r") do |f|
		$stdout.print f.read
	end
end
