class Renderer

	def initialize

	end

	# Set up the renderer with the surveys that will be rendered.
	def setup(surveys)
		@surveys = surveys
	end

	def render
		@surveys.each do |survey|
			# render survey HTML
			survey_html survey
		end

	end

	def survey_html(survey)
		puts '<form' + convert_for_id(survey.name) + '" class="survey_form" enctype="multipart/form-data" action="/sent" method="post">'
		survey.elements.each do |element|
			if element.class == Table
				table_html element
			# if child is table
				# render table HTML
					# calculate the maximum number of answers in question
					# draw outline of table 
					# while children have child
						# if child is question
							# render HTML appropriate for question
						# if child is hr
							# render HTML appropriate for hr
					# endwhile
			# if child is question
			elsif element.class == Question
				question_html element
				# render question HTML
			# if child is hr
				# render hr HTML
			# if child is group
			elsif element.class == Group
				if element.type == :open
					puts '<div' + convert_for_id(element.name) + ' class="survey_group">'
				elsif element.type == :close
					puts '</div>'
				end
			end
		end

		puts '</form>'
	end

	def table_html(table)
	end

	def question_html(question)
	end

	def convert_for_id(name)
		return '' if name == nil 

		return ' id="' + name.gsub(/\s/, '_') + '"'
	end

end