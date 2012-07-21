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
		@surveys.each do |survey|
			# render survey HTML
			survey_html survey
		end

	end

	def survey_html(survey)
		puts Mustache.render(@tag.survey_open, :id => (spaces_to_underscores survey.name))
		survey.elements.each do |element|
			if element.class == Table
				# table_html element
			# if child is question
			elsif element.class == Question
				question_html element
			# if child is hr
				# render hr HTML
			# if child is group
			elsif element.class == Group
				if element.type == :open
					puts Mustache.render(@tag.group_open, :id => (spaces_to_underscores element.name))
				elsif element.type == :close
					puts Mustache.render(@tag.group_close)
				end
			end
		end

		puts Mustache.render(@tag.survey_close)
	end

	def table_html(table)	
		# calculate the maximum number of answers in question
		# draw outline of table 
		# while children have child
			# if child is question
				# render HTML appropriate for question
			# if child is hr
				# render HTML appropriate for hr
		# endwhile
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
				widget_tag += Mustache.render(@tag.checkbox, { :name => name, :value => spaces_to_underscores(answer) })
			end
		when :file
			widget_tag = Mustache.render(@tag.file, :name => name)
		when :radio
			widget_tag = ''
			question.answers.each do |answer|
				widget_tag += Mustache.render(@tag.radio, { :name => name, :value => spaces_to_underscores(answer) })
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

		puts Mustache.render(@tag.question, { :heading_tag => heading_tag, :query_tag => query_tag, :instruction_tag => instruction_tag, :widget_tag => widget_tag })

	end

	def spaces_to_underscores(name)
		return '' if name == nil 
		return name.gsub(/\s/, '_').downcase
	end

end