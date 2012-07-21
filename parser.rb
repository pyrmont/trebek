require_relative 'Token'

class Parser
	
	def initialize

	end

	# Set up the parser with data that is going to be parsed.
	def setup(data)
		@data = data
	end

	def parse
		# while lines have a line
		@data.each_line do |line|
			puts 'The line is ' + line

			token = tokenize line

			# if line is a survey
			if line.match(/^Survey/)
				# create survey
				# puts 'Creating survey object...'
				# add to array of surveys
				# if survey param unset
					# set to survey param
				# else
					# raise error ('You have forgotten to close the previous survey.')
			# else if line is end of survey
				# if survey param set
					# unset survey param
				# else
					# raise error ('You have forgotten to create a survey.')
			# else if line is a group
				# if group param set
					# set group parent to be group param
				# set to group param
				# add to survey's children
			# else if line is end of group
				# if group param set
					# if group parent set
						# set group param to be group parent
					# else
						# unset group param
					# add to survey's children
				# else
					# raise error ('You have forgotten to create a group or you have closed too many groups.')
			end
			# else if line is a table
				# create table
				# if survey param set
					# add to survey's children
				# else
					# raise error ('You haven't created a survey but you're trying to close one.')
				# if table param unset
					# set to table param
				# else
					# raise error ('You have forgotten to close the previous table.')
			# else if line is end of table
				# if table param set
					# unset table param
				# else
					# raise error ('You haven't created a table yet but you're trying to close one.')
			# else if line is part of a question
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
			# else if line is blank
				# if question param set
					# unset question param
				# if question's question or heading is unset
					# raise error ('You have forgotten to write a question or a heading to identify this question.')
		end
	end

	def tokenize(chunk)
		chunk.strip!
		res = []
		if (res = chunk.scan(/^Survey( \w+|)/i)) && res.length > 0
			type = :survey
			line = res[0][0]
		elsif (res = chunk.scan(/^End Survey/i)) && res.length > 0
			type = :end_survey
			line = res[0][0]
		elsif (res = chunk.scan(/^Group( \w+|)/i)) && res.length > 0
			type = :group
			line = res[0][0]
		elsif (res = chunk.scan(/^End Group/i)) && res.length > 0
			type = :end_group
			line = res[0][0]
		elsif (res = chunk.scan(/^Table( \w+|)/i)) && res.length > 0
			type = :table
			line = res[0][0]
		elsif (res = chunk.scan(/^End Table/i)) && res.length > 0
			type = :end_table
			line = res[0][0]
		elsif (res = chunk.scan(/^Type:( .+|)/i)) && res.length > 0
			type = :question_type
			line = res[0][0]
		elsif (res = chunk.scan(/^heading:( .+|)/i)) && res.length > 0
			type = :question_heading
			line = res[0][0]
		elsif (res = chunk.scan(/^Required:( .+|)/i)) && res.length > 0
			type = :question_required
			line = res[0][0]
		elsif (res = chunk.scan(/^Question:( .+|)/i)) && res.length > 0
			type = :question_query
			line = res[0][0]
		elsif (res = chunk.scan(/^Instruction:( .+|)/i)) && res.length > 0
			type = :question_instruction
			line = res[0][0]
		elsif (res = chunk.scan(/^Answer:( .+|)/i)) && res.length > 0
			type = :question_answer
			line = res[0][0]
		elsif (res = chunk.scan(/^Default:( .+|)/i)) && res.length > 0
			type = :question_default
			line = res[0][0]
		# elsif chunk.match new line

		else
			# raise error
		end

		token = Token.new type, line

	end
end