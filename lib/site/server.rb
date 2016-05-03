require 'sinatra/base'

module Site

	class Server < Sinatra::Base

		get '/' do
			redirect to 'index.html'
		end

	end

end
