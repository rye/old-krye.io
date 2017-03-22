require 'sinatra/base'
require 'sinatra/advanced_routes'

require 'mime-types'

require 'tilt/sass'
require 'tilt/coffee'
require 'tilt/erb'

require 'site/cache'
require 'site/logger'

require 'base64'

module Site

	class Server < Sinatra::Base

		register Sinatra::AdvancedRoutes

		before '/' do
			request.path_info = '/index.html'
		end

		# Before all requests, set the Cache Control headers.
		before do
			cache_control :public, :must_revalidate, :max_age => 60
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
			# Register some MIME types.
			self.register_mimes!

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

			@@cache = Cache.new(env: ENV, application: self)

			@@routes = {}
		end

		def self.routes_update(routes, entry_filename)
			@@routes = {} if !@@routes

			routes.each do |route|
				if @@routes[route]
					Logger.debug "Server.routes_update" do "already have #{route}" end
				else
					Logger.debug "Server.routes_update" do "adding #{route}" end

					@@routes[route] = self.get route do
						lambda do
							slug = @@cache.get(entry_filename)

							etag slug["sha"]

							content_type MIME::Types.type_for(route).first.to_s

							Base64.decode64(slug["data"])
						end.call
					end
				end
			end
		end

		def self.routes_delete(routes)
			@@routes = {} if !@@routes

			routes.each do |route|
				if @@routes[route]
					Logger.debug "Server.routes_delete" do "deleting #{route}" end
					@@routes[route].deactivate
					@@routes.delete(route)
				else
					Logger.debug "Server.routes_delete" do "#{route} DNE, not deleting" end
				end
			end
		end

		# Starts the Sinatra application.
		def self.run!
			super
		end

		def self.register_mimes!
			register_mimes_for('application/x-eruby', ['html.erb', 'rhtml', 'erb'])
			register_mimes_for('application/x-sass', ['sass'])
			register_mimes_for('application/x-scss', ['scss'])
			register_mimes_for('application/x-coffee', ['coffee'])
		end

		def self.register_mimes_for(type, extensions)
			types = MIME::Type.new(type) do |mime_type|
				extensions.each do |extension|
					mime_type.add_extensions extension
				end
			end

			MIME::Types.add(types)
		end

	end

end
