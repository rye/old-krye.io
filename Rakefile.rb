$LOAD_PATH.unshift(File.expand_path(File.join('..', 'lib'), __FILE__))

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :tag do

	require 'site/logger'

	IO.popen(["ctags", "-eR", "--languages=ruby", "--verbose=yes", "--tag-relative=yes", "--exclude=.git", "--exclude=log", "."], "r") do |f|
		f.readlines.each do |line|
			Site::Logger.info 'ctags' do
				line.chomp
			end
		end
	end

end
