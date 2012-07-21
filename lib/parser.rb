require_relative 'Token'
require_relative 'Survey'
require_relative 'Group'
require_relative 'Table'
require_relative 'Question'

class Parser
	
	def initialize

	end

	# Set up the parser with data that is going to be parsed.
	def setup(data)
		@data = data
	end

	def parse
		# Tokenise the string
		tokens = []
		@data.each_line do |line|
			token = tokenize line
			tokens.push token
		end

		surveys = []
		groups = []
		current_survey = nil
		current_group = nil
		current_table = nil
		current_question = nil

		# Create the surveys
		tokens.each do |token|
			case token.type
			when :survey
				survey = Survey.new
				survey.name = token.content if token.content
				surveys.push survey
				if current_survey == nil
					current_survey = survey
				else
					# raise error ('You have forgotten to close the previous survey.')
					puts 'You have forgotten to close the previous survey.'
				end
			when :end_survey
				if current_survey
					current_survey = nil
				else
					# raise error ('You have forgotten to create a survey.')
					puts 'You have forgotten to create a survey.'
				end
			when :group
				group = Group.new :open
				group.name = token.content if token.content
				group.parent = current_group.position if current_group
				group.position = groups.length
				groups.push group
				current_group = group
				current_survey.elements.push group
			when :end_group
				group = Group.new :close
				if current_group
					current_group = (current_group.parent) ? groups[current_group.parent] : nil
					current_survey.elements.push group
				else
					# raise error ('You have forgotten to create a group or you have closed too many groups.')
					puts 'You have forgotten to create a group or you have closed too many groups.'
				end
			when :table
				table = Table.new
				table.name = token.content if token.content
				current_survey.elements.push table
				if current_table == nil
					current_table = table
				else
					# raise error ('You have forgotten to close the previous table.')
					puts 'You have forgotten to close the previous table.'
				end
			when :end_table
				if current_table
					current_table = nil
				else
					# raise error ('You are trying to close a table but none are open.')
					puts 'You are trying to close a table but none are open.'
				end
			when :question_required, :question_type, :question_heading, :question_query, :question_instruction, :question_default, :question_answer, :question_selected
				if current_question == nil
					question = Question.new
					current_question = question
					if current_table
						current_table.questions.push question
					else
						current_survey.elements.push question
					end
				else
					question = current_question
				end
				
				case token.type
				when :question_required
					question.required = token.content
				when :question_type
					question.type = token.content
				when :question_heading
					question.heading = token.content
				when :question_query
					question.query = token.content
				when :question_instruction
					question.instruction = token.content
				when :question_default
					question.default = token.content
				when :question_answer
					question.answers[(token.number - 1)] = token.content
				when :question_selected
					question.selected = token.content
				end
			# else if line is hr
				# if table param is set
					# add to table's children
				# else if survey param is set
					# add to survey's children
				# else
					# raise error ('You have forgotten to create a survey.')
			when :blank
				if current_question
					current_question = nil
				end
				# if question's question or heading is unset
					# raise error ('You have forgotten to write a question or a heading to identify this question.')
			end
		end

		return surveys
	end

	def tokenize(chunk)
		chunk.strip!
		result = []
		if (result = chunk.scan(/^Survey( .+|)/i)) && result.length > 0
			type = :survey
			line = result[0][0]
		elsif (result = chunk.scan(/^End Survey/i)) && result.length > 0
			type = :end_survey
			line = result[0][0]
		elsif (result = chunk.scan(/^Group( .+|)/i)) && result.length > 0
			type = :group
			line = result[0][0]
		elsif (result = chunk.scan(/^End Group/i)) && result.length > 0
			type = :end_group
			line = result[0][0]
		elsif (result = chunk.scan(/^Table( .+|)/i)) && result.length > 0
			type = :table
			line = result[0][0]
		elsif (result = chunk.scan(/^End Table/i)) && result.length > 0
			type = :end_table
			line = result[0][0]
		elsif (result = chunk.scan(/^Required: (Yes|No)/i)) && result.length > 0
			type = :question_required
			line = result[0][0]
		elsif (result = chunk.scan(/^Type: (Checkbox|File|Radio|Select|Text Area|Text|Toggle)/i)) && result.length > 0
			type = :question_type
			line = result[0][0]
		elsif (result = chunk.scan(/^Heading: (.+)/i)) && result.length > 0
			type = :question_heading
			line = result[0][0]
		elsif (result = chunk.scan(/^Question: (.+)/i)) && result.length > 0
			type = :question_query
			line = result[0][0]
		elsif (result = chunk.scan(/^Default: (.+)/i)) && result.length > 0
			type = :question_default
			line = result[0][0]
		elsif (result = chunk.scan(/^Instruction: (.+)/i)) && result.length > 0
			type = :question_instruction
			line = result[0][0]
		elsif (result = chunk.scan(/^Answer (\d+): (.+)/i)) && result.length > 0
			type = :question_answer
			line = result[0]
		elsif (result = chunk.scan(/^Selected: (\d+)/i)) && result.length > 0
			type = :question_selected
			line = result[0][0]
		elsif chunk == ''
			type = :blank
			line = nil
		else
			# raise error
		end

		token = Token.new type, line

	end
end