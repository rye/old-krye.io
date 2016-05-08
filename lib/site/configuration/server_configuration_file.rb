require 'site/configuration'

module Site
	module Configuration

		class ServerConfigurationFile < HashConfigurationFile

			attr_reader :filename

			def initialize(filename)
				super(filename)

				generate!
			end

			def environment; self['environment'] end
			def root_folder; File.expand_path(self['root_folder'], File.dirname(@filename)) end
			def public_folder; File.join(root_folder, self['public_folder']) end
			def skeleton_folder; File.join(root_folder, self['skeleton_folder']) end
			def views_folder; File.join(root_folder, self['views_folder']) end
			def erb_folder; File.join(views_folder, self['erb_folder']) end
			def scss_folder; File.join(views_folder, self['scss_folder']) end
			def coffee_folder; File.join(views_folder, self['coffee_folder']) end

			def show_exceptions?; self['show_exceptions'] end
			def bind; self['bind'] end
			def port; self['port'] end

			def custom_routes
				self['custom_routes']
			end

			protected

			def generate!
				spec = self.dup
				new = {}

				environment = spec['environment']
				environments = spec['environments']

				new['environment'] = environment.to_sym

				if default_environment = environments['__default__']
					new.merge!(default_environment)
				else
					raise StandardError.new('No __default__ environment in environments hash!')
				end

				if environment_spec = environments[environment]
					new.merge!(environment_spec)
				else
					raise StandardError.new("No supplemental spec in environments hash for given environment #{environment.inspect}!")
				end

				self.clear
				self.merge!(new)
			end

		end

	end
end
