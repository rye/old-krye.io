require 'sinatra/base'

require 'site/logger'
require 'site/compiler'

module Site

	class Server < Sinatra::Base

		def self.start(server_configuration)
			setup!(server_configuration)
			run!
		end

		protected

		def self.setup!(configuration)
			set :environment, configuration.environment if configuration.environment

			set :root, configuration.root_folder if configuration.root_folder
			set :public_folder, configuration.public_folder if configuration.public_folder

			set :show_exceptions, configuration.show_exceptions? if configuration.show_exceptions?

			set :logging, true

			set :bind, configuration.bind if configuration.bind
			set :port, configuration.port if configuration.port

			@@compiler ||= Compiler.new(configuration.root_folder, configuration.public_folder, configuration.skeleton_folder, erb: configuration.erb_folder, scss: configuration.scss_folder, coffee: configuration.coffee_folder)
		end

		def self.run!
			@@compiler.compile!
			@@compiler.run!

			super
		end

	end

end
