require 'redis'

require 'site/logger'

module Site

	class RedisAdapter < Adapter

		def initialize(env)
			super(env)

			redis_host = ENV['REDIS_HOST']
			redis_port = ENV['REDIS_PORT']
			redis_password = ENV['REDIS_PASSWORD']

			redis_opts = {}
			redis_opts[:host] = redis_host if redis_host
			redis_opts[:port] = redis_port if redis_port
			redis_opts[:password] = redis_password if redis_password

			redis_opts.tap do |hash|
				filter_keys = [:password]

				printable_opts = hash.map do |key, value|
					filter_keys.include?(key) ? [key, "[FILTERED]"] : [key, value]
				end.to_h

				Logger.info "cache" do
					"Connecting to Redis with opts #{printable_opts}"
				end
			end

			@redis = Redis.new redis_opts

			begin
				result = @redis.ping
				Logger.info "Redis responded to PING, ready to roll..."
			rescue Exception => e
				Logger.dump_exception e
				Logger.warn "Closing on exception in DB connection."

				exit 1
			end
		end

		def store(key, object)
			data = JSON.generate(object)
			@redis.set key, data
		end

		def contains?(key)
			@redis.exists key
		end

		def get(key)
			data = @redis.get key
			JSON.parse(data) if data
		end

		def delete(key)
			@redis.delete key
		end

	end

end
