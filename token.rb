class Token

	def initialize(type, line)
		@type = type
		@content = generate line
	end

	def generate(line)
		result = nil
		case @type
		when :survey || :group || :table
			case @type
			when :survey
				matches = line.scan(/Survey( \w*|)/i)
			when :group
				matches = line.scan(/Group( \w*|)/i)
			when :table
				matches = line.scan(/Table( \w*|)/i)
			end

			if name = matches[0][0]
				result = (name != '') ? name.strip : nil
			end

			puts result.inspect
		
			result = nil
		when :end_survey || :end_group || :end_table
			result = nil
		end

		return result
	end

end