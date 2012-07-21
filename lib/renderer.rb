require 'mustache'
require_relative 'Tag'

class Renderer

	def initialize
		@tag = Tag.new
		@question_number = 0
	end

	# Set up the renderer with the surveys that will be rendered.
	def setup(surveys)
		@surveys = surveys
	end

	def render
		html = ''

		@surveys.each do |survey|
			# render survey HTML
			html += survey_html survey
		end

		return html
	end

	def survey_html(survey)
		html = Mustache.render(@tag.survey_open, :id => (spaces_to_underscores survey.name))
		survey.elements.each do |element|
			if element.class == Table
				html += table_html element
			# if child is question
			elsif element.class == Question
				html += question_html element
			# if child is hr
				# render hr HTML
			# if child is group
			elsif element.class == Group
				if element.type == :open
					html += Mustache.render(@tag.group_open, :id => (spaces_to_underscores element.name))
				elsif element.type == :close
					html += Mustache.render(@tag.group_close)
				end
			end
		end

		html += Mustache.render(@tag.survey_close)

		return html
	end

	def table_html(table)	
		# draw outline of table
		example_answers = table.questions[0].answers
		answers = []
		example_answers.each do |example_answer|
			answer = Hash.new
			answer[:answer] = example_answer
			answers.push(answer)
		end

		html = Mustache.render(@tag.table_open, :answers => answers)

		table.questions.each do |question|
			if question.name
				name = question.name
			else
				name = 'question_' + @question_number.to_s
				@question_number = @question_number + 1
			end

			responses = []
			question.answers.each do |answer|
				widget_tag = ''
				case question.type
				when :checkbox
					widget_tag = Mustache.render(@tag.checkbox, { :name => name, :value => spaces_to_underscores(answer) })
				when :radio
					widget_tag = Mustache.render(@tag.radio, { :name => name, :value => spaces_to_underscores(answer) })
				end
				response = Hash.new
				response[:response] = widget_tag
				responses.push response
			end
			html += Mustache.render(@tag.table_row, {:query => question.query, :responses => responses } )
		end

		html += Mustache.render(@tag.table_close)

		return html
	end

	def question_html(question)
		if question.name
			name = question.name
		else
			name = 'question_' + @question_number.to_s
			@question_number = @question_number + 1
		end

		heading_tag = Mustache.render(@tag.heading, :heading => question.heading) if question.heading
		query_tag = Mustache.render(@tag.query, :query => question.query) if question.query
		instruction_tag = Mustache.render(@tag.instruction, :instruction => question.instruction) if question.instruction
		
		case question.type
		when :checkbox
			widget_tag = ''
			question.answers.each do |answer|
				id = name + '_' + spaces_to_underscores(answer)
				widget_tag += Mustache.render(@tag.checkbox, { :id => id, :name => name, :value => spaces_to_underscores(answer) })
				widget_tag += Mustache.render(@tag.label, { :id => id, :response => answer })
			end
		when :file
			widget_tag = Mustache.render(@tag.file, :name => name)
		when :radio
			widget_tag = ''
			question.answers.each do |answer|
				id = name + '_' + spaces_to_underscores(answer)
				widget_tag += Mustache.render(@tag.radio, { :id => id, :name => name, :value => spaces_to_underscores(answer) })
				widget_tag += Mustache.render(@tag.label, { :id => id, :response => answer })
			end
		when :select
			responses = []
			question.answers.each do |answer|
				response = Hash.new
				response[:label] = answer
				response[:value] = spaces_to_underscores(answer)
				responses.push(response)
			end
			widget_tag = Mustache.render(@tag.select, { :name => name, :responses => responses })
		when :text_area
			widget_tag = Mustache.render(@tag.text_area, { :name => name, :default => question.default })
		when :text
			widget_tag = Mustache.render(@tag.text, { :name => name, :default => question.default})
		when :toggle
		end

		html = Mustache.render(@tag.question, { :heading_tag => heading_tag, :query_tag => query_tag, :instruction_tag => instruction_tag, :widget_tag => widget_tag })

		return html
	end

	def spaces_to_underscores(name)
		return '' if name == nil 
		return name.gsub(/\s/, '_').downcase
	end

end