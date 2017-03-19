require 'logger'

require 'site/multi_delegator'

module Site

	LOG_FILE = File.open(File.expand_path(File.join('..', '..', '..', 'log', "site-#{File.basename $0}-#{Process.pid}.log"), __FILE__), 'a')
	LOG_FILE.sync = true

	# This is the logger that we use in our app.
	Logger = Logger.new MultiDelegator.delegate(:write, :close).to(STDOUT, LOG_FILE)
	self::Logger.level = ::Logger::INFO

	def Logger.dump_exception(exception)
		begin
			filename, line, rest = caller[0].split(':')

			file_pathname = Pathname.new(filename)
			basename = file_pathname.relative_path_from(Pathname.new(Site::ROOT_DIRECTORY))

			program_name = "#{basename}:#{line}"
			prefix = "#{rest}: "

			error(program_name) { "#{prefix}#{exception.message}" }

			exception.backtrace.each do |line|
				debug(program_name) { "#{prefix}#{line}" }
			end
		rescue Exception => exception
			abort "got exception in dump_exception: #{exception.message}... agh"
		end
	end

end
