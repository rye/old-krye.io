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

	task :to_development do
	end
end

namespace :documentation do
	task :generate do
		require 'mkmf'
		require 'yaml'
		require 'site/logger'

		module MakeMakefile::Logging
			@quiet = true
			@logfile = File::NULL
		end

		Site::Logger.info "Finding root_directory"

		root_directory = File.expand_path(File.join('..'), __FILE__)

		Site::Logger.debug "root_directory: #{root_directory}"

		Site::Logger.info "Reading config/docs.yml"

		data = open(File.join(root_directory, 'config', 'docs.yml'), 'rb') do |io|
			io.read
		end

		configuration = YAML.load(data)

		file_rules = configuration['files']

		raise RuntimeError, 'No file rules. :(' unless file_rules

		files_to_document = []

		file_rules.each do |file_rule|
			Site::Logger.debug "Finding files for file_rule #{file_rule}"

			file_rule_files = Dir.glob(File.join(root_directory, file_rule)).tap do |_matches|
				Site::Logger.debug "Have #{_matches.count} matches to the file_rule"
			end.select do |match|
				type = case File.ftype match
							 when 'file'
								 :file
							 when 'directory'
								 :directory
							 else
								 :unknown
							 end

				Site::Logger.debug "#{match} is a #{type}"

				type == :file
			end.tap do |_files|
				Site::Logger.info "Have #{_files.count} to add to the list"
			end

			Site::Logger.info "Currently have #{files_to_document.count} files to document"

			files_to_document << file_rule_files

			files_to_document.flatten!

			Site::Logger.info "Now have #{files_to_document.count} files to document"
		end

		Site::Logger.info "Beginning documentation procedure"

		docco_files = files_to_document.join(' ')

		raise RuntimeError, 'Executable `docco` could not be found! Ensure you have it installed!' unless find_executable 'docco'

		IO.popen("docco #{docco_files}").each do |line|
			Site::Logger.debug 'docco' do line.strip end
		end

		Site::Logger.info "Done."
	end
end
