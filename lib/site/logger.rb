require 'logger'

module Site

	Logger = Logger.new(STDOUT)
	self::Logger.level = ::Logger::INFO

end
