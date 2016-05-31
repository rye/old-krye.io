require 'sinatra/base'

require 'site/logger'
require 'site/compiler'

module Site

	class Server < Sinatra::Base

		get '/' do
			if File.exist?(filename = File.join(settings.public_folder, 'index.html'))
				open(filename, 'rb') do |io|
					io.read
				end
			else
				redirect to '/index.html'
			end
		end

		def self.prepare!
			setup!
			compile!
			run_compiler!
		end

		def self.start
			prepare!
			run!
		end

		def self.setup!
			@@root_folder = File.expand_path(File.join('..', '..'), File.dirname(__FILE__))
			@@public_folder = File.expand_path(File.join(@@root_folder, 'tmp', '_static'))
			@@skeleton_folder = File.expand_path(File.join(@@root_folder, 'static'))
			@@views_folder = File.expand_path(File.join(@@root_folder, 'views'))
			@@__erb_folder__ = File.expand_path(File.join(@@views_folder, '__erb__'))
			@@__scss_folder__ = File.expand_path(File.join(@@views_folder, '__scss__'))
			@@__coffee_folder__ = File.expand_path(File.join(@@views_folder, '__coffee__'))

			set :root, @@root_folder
			set :public_folder, @@public_folder

			set :show_exceptions, false

			set :logging, true

			@@compiler ||= Compiler.new(@@root_folder, @@public_folder, @@skeleton_folder, erb: @@__erb_folder__, scss: @@__scss_folder__, coffee: @@__coffee_folder__)
		end

		def self.compile!
			@@compiler.compile!
		end

		def self.run_compiler!
			@@compiler.run!
		end

		def self.run!
			super
		end

	end

end
