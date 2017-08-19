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

		before do
			if @@aliases[request.path_info]
				request.path_info = @@aliases[request.path_info]
			end
		end

		# Before all requests, set the Cache Control headers.
		before do
			cache_control :public, :must_revalidate, :max_age => 60
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

			@@routes = {}
			@@aliases = {}

			@@cache = Cache.new(env: ENV, application: self)
		end

		def self.set_routes(filename, tag, route, aliases)
			@@routes = {} if !@@routes
			@@aliases = {} if !@@aliases

			if existing_route = @@routes[route]
				# Route to be updated already exists.
				if existing_route[:tag] == tag
					# Route to be updated is identical to new version, NOOP.
				elsif !existing_route[:tag] != tag
					# Route to be updated has different tag.
					#
					# Then, deactivate and set new tag.
					existing_route[:route].deactivate if existing_route[:route].respond_to?(:deactivate)

					@@aliases.select do |key, value|
						value == route
					end.each do |alyas|
						@@aliases.delete(alyas)
					end

					@@routes.delete(route)
					@@routes[route] = {tag: tag}
					@@routes[route][:route] = self.default_get_route(filename, tag, route.to_s)

					aliases.each do |alyas|
						@@aliases[alyas] = route
					end
				end
			else
				# Route to be updated does not already exist.
				@@routes[route] = {tag: tag}
				@@routes[route][:route] = self.default_get_route(filename, tag, route.to_s)

				aliases.each do |alyas|
					@@aliases[alyas] = route
				end
			end
		end

		def self.default_get_route(filename, tag, path)
			self.get(path) do
				lambda do
					slug = @@cache.get(filename, tag)

					etag slug["digest"]

					content_type MIME::Types.type_for(path).first.to_s

					Base64.decode64(slug["data"])
				end.call
			end
		end

		def self.deactivate_route(route, aliases)
			@@routes = {} if !@@routes
			@@routes[route][:route].deactivate if @@routes[:route].respond_to?(:deactivate)
			@@routes.delete(route)

			aliases.select do |key, value|
				value == route
			end.each do |alyas|
				@@aliases.delete(alyas)
			end
		end

		get '/aliases.json' do
			content_type :json
			JSON.generate(@@aliases)
		end

		get '/routes.json' do
			content_type :json

			routes_filtered = @@routes.dup.map do |route, spec|
				[route, spec[:tag]]
			end.to_h

			JSON.generate(routes_filtered)
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
