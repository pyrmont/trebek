require_relative 'Token'

class Parser

	attr_reader :in_survey, :in_group, :in_table, :in_question
	
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

		tokens.each do |token|
			case token.type
			# if line is a survey
			when :survey
				# create survey
				puts 'Creating survey object...'
				# add to array of surveys
				puts 'Adding to array of surveys...'
				# if survey param unset
				if @in_survey == false
					# set to survey param
					@in_survey = true
				else
					# raise error ('You have forgotten to close the previous survey.')
					puts 'You have forgotten to close the previous survey.'
				end
			when :end_survey
				puts 'End of survey reached.'
				# if survey param set
					# unset survey param
				# else
					# raise error ('You have forgotten to create a survey.')
			when :group
				puts 'Creating group...'
				# if group param set
					# set group parent to be group param
				# set to group param
				# add to survey's children
			when :end_group
				puts 'End of group reached.'
				# if group param set
					# if group parent set
						# set group param to be group parent
					# else
						# unset group param
					# add to survey's children
				# else
					# raise error ('You have forgotten to create a group or you have closed too many groups.')
			when :table
				# create table
				puts 'Creating table...'
				# if survey param set
					# add to survey's children
				# else
					# raise error ('You haven't created a survey but you're trying to close one.')
				# if table param unset
					# set to table param
				# else
					# raise error ('You have forgotten to close the previous table.')
			when :end_table
				puts 'End of table reached.'
				# if table param set
					# unset table param
				# else
					# raise error ('You haven't created a table yet but you're trying to close one.')
			when :question_required, :question_type, :question_heading, :question_query, :question_instruction, :question_default, :question_answer, :question_selected
				puts 'Creating elements of question...'
				# if question param unset
					# create question
					# if table param set
						# add to table's children
					# else if survey param set
						# add to survey's children
					# else
						# raise error ('You have forgotten to create a survey.')
				# else if question param set and this part of the question set
					# raise error ('You are trying to define the same part of the question twice.')
				# add to question
			# else if line is hr
				# if table param is set
					# add to table's children
				# else if survey param is set
					# add to survey's children
				# else
					# raise error ('You have forgotten to create a survey.')
			when :blank
				puts 'This is a new line.'
				# if question param set
					# unset question param
				# if question's question or heading is unset
					# raise error ('You have forgotten to write a question or a heading to identify this question.')
			end
		end
	end

	def tokenize(chunk)
		chunk.strip!
		result = []
		if (result = chunk.scan(/^Survey( \w+|)/i)) && result.length > 0
			type = :survey
			line = result[0][0]
		elsif (result = chunk.scan(/^End Survey/i)) && result.length > 0
			type = :end_survey
			line = result[0][0]
		elsif (result = chunk.scan(/^Group( \w+|)/i)) && result.length > 0
			type = :group
			line = result[0][0]
		elsif (result = chunk.scan(/^End Group/i)) && result.length > 0
			type = :end_group
			line = result[0][0]
		elsif (result = chunk.scan(/^Table( \w+|)/i)) && result.length > 0
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