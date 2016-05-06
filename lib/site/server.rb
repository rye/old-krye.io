require 'sinatra/base'

module Site

	class Server < Sinatra::Base

		def self.start(server_configuration)
			run!(server_configuration)
		end

		protected

		def self.setup!(configuration)
			set :environment, configuration.environment

			set :root, File.expand_path(configuration.root_folder)
			set :public_folder, configuration.public_folder
			set :views, configuration.views_folder

			set :sessions, configuration.sessions?
			set :show_exceptions, configuration.show_exceptions

			set :bind, configuration.bind
			set :port, configuration.port

			p settings.public_folder
			p settings.views
		end

		def self.run!(configuration)
			setup!(configuration)

			super()
		end

	end

end
