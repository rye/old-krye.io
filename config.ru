$LOAD_PATH.unshift(File.expand_path(File.join('lib'), File.dirname(__FILE__)))

require 'site'

server_configuration = Site::ServerConfiguration.new 'config/server.yml'
