$LOAD_PATH.unshift(File.expand_path(File.join('..', 'lib'), __FILE__))

namespace :update do
	task :production do
		require 'site/logger'

		Site::Logger.level = ::Logger::DEBUG

		Site::Logger.info 'update:production' do
			"Running `bundle install --deployment --without development test`"
		end

		IO.popen('bundle install --deployment --without development test').each do |line|
			Site::Logger.debug 'update:production <bundle>' do line.strip end
		end
	end
end
