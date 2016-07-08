require 'logger'

require 'site/multi_delegator'

module Site

	LOG_FILE = File.open(File.expand_path(File.join('..', '..', '..', 'log', "site-#{File.basename $0}-#{Process.pid}.log"), __FILE__), 'a')

	# This is the logger that we use in our app.
	Logger = Logger.new MultiDelegator.delegate(:write, :close).to(STDOUT, LOG_FILE)
	self::Logger.level = ::Logger::INFO

end
