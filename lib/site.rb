require 'site/cache'
require 'site/logger'
require 'site/multi_delegator'
require 'site/server'

module Site

	def Site.root_directory
		File.expand_path(File.join('..', '..'), __FILE__)
	end

	def Site.static_directory
		File.expand_path(File.join(Site.root_directory, 'static'))
	end

	def Site.views_directory
		File.expand_path(File.join(Site.root_directory, 'views'))
	end

	def Site.git_version_string
		`git describe --tags --dirty`.chomp
	end

end
