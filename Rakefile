$LOAD_PATH.unshift(File.expand_path(File.join('..', 'lib'), __FILE__))

namespace :update do
	task :to_production do
		require 'site/logger'

		Site::Logger.info 'update:production' do
			"Running `bundle install --deployment --without development test`"
		end

		IO.popen('bundle install --deployment --without development test').each do |line|
			Site::Logger.debug 'update:production <bundle>' do line.strip end
		end
	end
end

namespace :documentation do
	task :generate do
		require 'mkmf'
		require 'site/logger'

		module MakeMakefile::Logging
			@quiet = true
			@logfile = File::NULL
		end

		Site::Logger.info 'documentation:generate' do
			"Locating lib_directory"
		end

		lib_directory = Dir.glob(File.expand_path(File.join('..', 'lib'), __FILE__))

		Site::Logger.debug 'documentation:generate' do
			"lib_directory: #{lib_directory}"
		end

		Site::Logger.info 'documentation:generate' do
			"Locating lib_files"
		end

		lib_files = Dir.glob(File.join(lib_directory, '**', '*')).tap do |_lib_files|
			Site::Logger.debug 'documentation:generate' do
				"Have #{_lib_files.count} matches"
			end
		end.select do |_lib_file|
			# Infer the type of `_lib_file` from the results of
			# `File.ftype`, which returns a custom `String` result.
			type = case File.ftype _lib_file
			       when 'file'
				       :file
			       when 'directory'
				       :directory
			       else
				       :unknown
			       end

			Site::Logger.debug 'documentation:generate' do
				"#{_lib_file} is a #{type}"
			end

			type == :file
		end.tap do |_lib_files|
			Site::Logger.info 'documentation:generate' do
				"Have #{_lib_files.count} *files*; these will be parsed together"
			end
		end

		docco_files = lib_files.join(' ')

		raise RuntimeError, 'Executable `docco` could not be found! Ensure you have it installed!' unless find_executable 'docco'

		IO.popen("docco #{docco_files}").each do |line|
			Site::Logger.debug 'documentation:generate' do line.strip end
		end
	end
end
