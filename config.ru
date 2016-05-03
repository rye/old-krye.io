$LOAD_PATH.unshift(File.expand_path(File.join('lib'), File.dirname(__FILE__)))

require 'site'

run Site::Server
