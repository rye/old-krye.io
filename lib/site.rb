require 'site/cache'
require 'site/logger'
require 'site/multi_delegator'
require 'site/server'

module Site

	ROOT_DIRECTORY = File.expand_path(File.join('..', '..'), __FILE__)
	STATIC_DIRECTORY = File.expand_path(File.join(ROOT_DIRECTORY, 'static'))
	VIEWS_DIRECTORY = File.expand_path(File.join(ROOT_DIRECTORY, 'views'))

end
