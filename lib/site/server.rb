require 'sinatra/base'

require 'site/logger'
require 'site/compiler'

module Site

	class Server < Sinatra::Base

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

		# Runs all of the hooks necessary to prepare the server for execution.
		def self.prepare!
			setup!
			compile!
			run_compiler!
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
			@@public_folder = File.expand_path(File.join(@@root_folder, 'tmp', '_static'))
			@@skeleton_folder = File.expand_path(File.join(@@root_folder, 'static'))
			@@views_folder = File.expand_path(File.join(@@root_folder, 'views'))
			@@__erb_folder__ = File.expand_path(File.join(@@views_folder, '__erb__'))
			@@__scss_folder__ = File.expand_path(File.join(@@views_folder, '__scss__'))
			@@__coffee_folder__ = File.expand_path(File.join(@@views_folder, '__coffee__'))

			# Assert that all of the folders exist.
			#
			# * This should get cleaned up and made a bit more magical.
			[@@root_folder, @@public_folder, @@skeleton_folder, @@views_folder, @@__erb_folder__, @@__scss_folder__, @@__coffee_folder__].each do |folder|
				raise RuntimeError, "Folder #{folder} does not exist!" unless File.directory? folder
			end

			# Set some settings so that Sinatra can find our static files.
			set :root, @@root_folder
			set :public_folder, @@public_folder

			# Don't show exceptions. (This could get ugly and bad in production)
			set :show_exceptions, false

			# Do log to the console.
			set :logging, true

			# Finally, create a new instance of `Compiler`, give it all of our folders.
			@@compiler ||= Compiler.new(@@root_folder, @@public_folder, @@skeleton_folder, erb: @@__erb_folder__, scss: @@__scss_folder__, coffee: @@__coffee_folder__)
		end

		# Compiles the site.
		def self.compile!
			@@compiler.compile!
		end

		# Starts the Compiler.
		def self.run_compiler!
			@@compiler.run!
		end

		# Starts the Sinatra application.
		def self.run!
			super
		end

	end

end
