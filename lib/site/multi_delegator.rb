module Site

	# This class is primarily responsible for dealing
	# with distributing calls between `Object`s; this enables us to
	# make calls between each of the `Object`s by calling them on
	# the `MultiDelegator` object instead.
	class MultiDelegator
		def initialize(*targets)
			@targets = targets
		end

		def self.delegate(*methods)
			methods.each do |method|
				define_method(method) do |*arguments|
					@targets.map do |target|
						target.send(method, *arguments)
					end
				end
			end

			self
		end

		class << self
			alias to new
		end
	end

end
