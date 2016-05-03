require 'sinatra/base'

module Site

	class Server < Sinatra::Base

		def self.start(server_configuration)
			public_folder = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', server_configuration.default_static_folder))

			set :public_folder, public_folder

			self
		end

	end

end
