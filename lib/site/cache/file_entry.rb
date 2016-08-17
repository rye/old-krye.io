module Site

	class FileEntry

		attr_reader :readable_filename
		attr_reader :encoded_contents
		attr_reader :contents
		attr_reader :mime_types
		attr_reader :type

		def initialize(readable_filename, encoded_contents, contents, mime_types, type)
			@readable_filename, @encoded_contents, @contents, @mime_types, @type =
				readable_filename, encoded_contents, contents, mime_types, type
		end

	end

end
