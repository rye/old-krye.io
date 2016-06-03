require 'sinatra/base'

require 'tilt/sass'
require 'tilt/coffee'
require 'tilt/erb'

require 'site/logger'

module Site

	class Server < Sinatra::Base

		Tilt.register :"html.erb", Tilt[:erb]

		# Default route to /
		get '/' do
			if File.exist?(filename = File.join(settings.public_folder, 'index.html'))
				# If we have an index.html file in our static folder, read it.
				open(filename, 'rb') do |io|
					io.read
				end
			else
				# Otherwise try to redirect to the /index.html file. This should
				# never really get hit; you should always have an index.html file.
				redirect to '/index.html'
			end
		end

		get '/:__route__.?:__extension__?' do
			if File.readable?(filename = File.join(settings.views, params['__route__'] + (params['__extension__'] ? '.' + params['__extension__'] : '.html') + '.erb'))
				@data = open(filename, 'rb') do |io|
					io.read
				end

				erb @data
			else
				404
			end
		end

		get '/js/:__script__.js' do
			if File.readable?(filename = File.join(settings.views, 'js', params['__script__'] + '.coffee'))
				@data = open(filename, 'rb') do |io|
					io.read
				end

				coffee @data
			else
				404
			end
		end

		get '/css/:__stylesheet__.css' do
			if File.readable?(filename = File.join(settings.views, 'css', params['__stylesheet__'] + '.scss') || File.join(settings.views, 'css', params['__stylesheet__'] + '.sass'))
				@data = open(filename, 'rb') do |io|
					io.read
				end

				scss @data
			else
				404
			end
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
			# Do a little bit of analysis to generate file paths.
			@@root_folder = File.expand_path(File.join('..', '..'), File.dirname(__FILE__))
			@@public_folder = File.expand_path(File.join(@@root_folder, 'static'))
			@@views_folder = File.expand_path(File.join(@@root_folder, 'views'))

			# Assert that all of the folders exist.
			#
			# * This should get cleaned up and made a bit more magical.
			[@@root_folder, @@public_folder, @@views_folder].each do |folder|
				raise RuntimeError, "Folder #{folder} does not exist!" unless File.directory? folder
			end

			# Set some settings so that Sinatra can find our static files.
			set :root, @@root_folder
			set :public_folder, @@public_folder
			set :views, @@views_folder

			# Don't show exceptions. (This could get ugly and bad in production)
			set :show_exceptions, false

			# Do log to the console.
			set :logging, true
		end

		# Starts the Sinatra application.
		def self.run!
			super
		end

	end

end
