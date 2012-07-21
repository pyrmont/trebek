require 'mustache'
require_relative 'Tag'

class Renderer

	def initialize
		@tag = Tag.new
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
		puts Mustache.render(@tag.survey_open, :id => (convert_for_id survey.name))
		survey.elements.each do |element|
			if element.class == Table
				# table_html element
			# if child is question
			elsif element.class == Question
				# question_html element
			# if child is hr
				# render hr HTML
			# if child is group
			elsif element.class == Group
				if element.type == :open
					puts Mustache.render(@tag.group_open, :id => (convert_for_id element.name))
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
		if question.heading
		end

		if question.query
		end

		if question.instruction
		end

		case question.type
		when :checkbox
		when :file
		when :radio
		when :select
		when :text_area
		when :text
		when :toggle
		end

	end

	def convert_for_id(name)
		return '' if name == nil 

		return name.gsub(/\s/, '_')
	end

end