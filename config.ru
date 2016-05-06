$LOAD_PATH.unshift(File.expand_path(File.join('lib'), File.dirname(__FILE__)))

require 'site'
require 'pp'

server_configuration = Site::ServerConfiguration.new 'config/server.yml'

pp server_configuration

require 'sinatra'

disable :run

map '/' do
	server = Site::Server.setup!(server_configuration)

	run server
end
