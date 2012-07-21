class Token

	attr_accessor :type, :number, :content

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
			when 'Text Area'
				result = :text_area
			when 'Text'
				result = :text
			when 'Toggle'
				result = :toggle
			end
		when :question_required, :question_heading, :question_query, :question_instruction, :question_default
			result = line
		when :question_answer
			@number = Integer(line[0])
			result = line[1]
		when :question_selected
			result = Integer(line)
		when :end_survey, :end_group, :end_table
			result = nil
		when :empty
			result = nil
		end

		return result
	end

end