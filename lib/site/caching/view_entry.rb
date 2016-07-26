require 'tilt'

require 'site/caching/entry'

module Site
  module Caching

    class ViewEntry < Entry

      def initialize(filename:, mime_type:)
        @filename, @mime_type = filename, mime_type

        encode!
      end

      def read!
        begin
          @contents = Tilt.new(@filename, default_encoding: 'UTF-8').render
        rescue RuntimeError, /No template engine/
          @contents = read_file(@filename)
        end
      end

      def encode!
        read!

        @sha1 = encode(@contents || '')
      end

      protected

      def read_file(filename)
        open(filename, 'rb') do |io|
          io.read
        end
      end

    end

  end
end
