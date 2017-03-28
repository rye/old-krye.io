require 'redis'

require 'site/logger'

require 'site/cache/adapter'

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

			redis_opts.tap do |opts|
				filtered_opts = [:password]

				printable_opts = replace_values(opts, filtered_opts, "[FILTERED]")

				Logger.info "redis_adapter" do
					"Connecting to Redis with opts #{printable_opts}"
				end
			end

			@redis = Redis.new redis_opts

			begin
				ping

				Logger.info "redis_adapter" do
					"Redis PONG-ed, ready to roll..."
				end
			rescue Exception => e
				Logger.dump_exception e
				Logger.warn "redis_adapter" do
					"Aborting startup due to exception in connection to Redis."
				end

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

		def expire(key, ttl)
			@redis.expire(key, ttl)
		end

		def ping
			@redis.ping
		end

		protected

		# Replaces values in `hash` corresponding to any of the
		# `filtered_keys` with `new_value`.
		#
		# Useful for situations like filtering plaintext passwords.
		def replace_values(hash, filtered_keys = [], new_value = nil)
			hash.map do |key, value|
				(filtered_keys.include?(key) && new_value) ? [key, new_value] : [key, value]
			end.to_h
		end

	end

end
