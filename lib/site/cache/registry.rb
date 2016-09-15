module Site

	class Registry < Hash

		attr_accessor :semaphore

		def initialize
			@semaphore = Mutex.new
		end

	end

end
