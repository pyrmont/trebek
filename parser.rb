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
		if chunk.match(/^Survey/i)
			token = Token.new :survey, chunk
		elsif chunk.match(/^End Survey/i)
			token = Token.new :end_survey, chunk
		elsif chunk.match(/^Group/i)
			token = Token.new :group, chunk
		elsif chunk.match(/^End Group/i)
			token = Token.new :end_group, chunk
		elsif chunk.match(/^Table/i)
			token = Token.new :table, chunk
		elsif chunk.match(/^End Table/i)
			token = Token.new :end_table, chunk
		elsif chunk.match(/^Type/i)

		elsif chunk.match(/^Heading/i)

		elsif chunk.match(/^Required/i)

		elsif chunk.match(/^Question/i)

		elsif chunk.match(/^Instruction/i)

		elsif chunk.match(/^Answer/i)

		elsif chunk.match(/^Default/i)

		# elsif chunk.match new line

		else
			# raise error
		end

	end
end