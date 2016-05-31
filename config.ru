$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'site'

Site::Server.prepare!

run Site::Server
