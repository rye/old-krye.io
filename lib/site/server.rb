require 'sinatra/base'
require 'sinatra/advanced_routes'

require 'tilt/sass'
require 'tilt/coffee'
require 'tilt/erb'

require 'site/cache'
require 'site/logger'

require 'thread'

module Site

	class Server < Sinatra::Base

		register Sinatra::AdvancedRoutes

		@@printing_semaphore = Mutex.new

		Tilt.register :"html.erb", Tilt[:erb]

		before '/' do
			request.path_info = '/index.html'
		end

		# Before all requests, set the Cache Control headers.
		before do
			cache_control :public, :must_revalidate, :max_age => 60
		end

		after do
			@@printing_semaphore.synchronize {
				Site::Logger.warn "Handled request for #{request.path_info.to_s.inspect}"
			}
		end

		get '/' do
			redirect '/index.html'
		end

		# Runs all of the hooks necessary to prepare the server for execution.
		def self.prepare!
			setup!
		end

		# Starts the server (this blocks until the server is killed; don't
		# use this in Rack apps but it's fine for using in binaries or on
		# new threads.
		def self.start
			prepare!
			run!
		end

		# Sets up the server
		def self.setup!
			# Set some settings so that Sinatra can find our static files.
			set :root, Site::ROOT_DIRECTORY
			set :public_folder, Site::STATIC_DIRECTORY
			set :views, Site::VIEWS_DIRECTORY

			# Don't show exceptions. (This could get ugly and bad in production)
			set :show_exceptions, false

			# Disable builtin static file serving and static cache control.
			set :static, false
			set :static_cache_control, false

			# Do log to the console.
			set :logging, true

			@@cache = Cache.new(application: self)

			@@cache.dump!
		end

		# Starts the Sinatra application.
		def self.run!
			super
		end

	end

end
