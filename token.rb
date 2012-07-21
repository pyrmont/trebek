class Token

	def initialize(type, line)
		@type = type
		@content = generate line
	end

	def generate(line)
		result = nil
		case @type
		when :survey, :group, :table
			case @type
			when :survey
				matches = line.scan(/^Survey( \w*|)/i)
			when :group
				matches = line.scan(/^Group( \w*|)/i)
			when :table
				matches = line.scan(/^Table( \w*|)/i)
			end

			if name = matches[0][0]
				result = (name != '') ? name.strip : nil
			end
		when :question_type
			matches = line.scan(/^Type: (.*)/i)
			case matches[0][0]
			when 'Checkbox'
				result = :checkbox
			when 'File'
				result = :file
			when 'Radio'
				result = :radio
			when 'Select'
				result = :select
			when 'Text'
				result = :text
			when 'Text Area'
				result = :text_area
			end
		when :question_heading
		when :question_required
		when :question_query
		when :question_instruction
		when :question_answer
		when :question_default
		when :end_survey, :end_group, :end_table
			result = nil
		end

		puts result.inspect
		return result
	end

end