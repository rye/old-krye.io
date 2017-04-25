module Site

	class Version

		def initialize(major:, minor: 0, patch: 0, prerelease: nil)
			@major, @minor, @patch, @prerelease = major, minor, patch, prerelease
		end

	end

end
