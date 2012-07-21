class Token

	def initialize(type, line)
		@type = type
		@content = generate line
	end

	def generate(line)
		result = nil
		case @type
		when :survey, :group, :table
			if name = line
				result = (name != '') ? name.strip : nil
			end
		when :question_type
			case line
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

		# puts result.inspect
		return result
	end

end