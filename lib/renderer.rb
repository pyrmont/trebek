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
				question_html element
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
		heading_tag = Mustache.render(@tag.heading, :heading => question.heading) if question.heading
		query_tag = Mustache.render(@tag.query, :query => question.query) if question.query
		instruction_tag = Mustache.render(@tag.instruction, :instruction => question.instruction) if question.instruction

		case question.type
		when :checkbox
		when :file
			widget_tag = Mustache.render(@tag.file)
		when :radio
			widget_tag = ''
			question.answers.each do |answer|
				widget_tag += Mustache.render(@tag.radio, :value => answer)
			end
		when :select
		when :text_area
		when :text
			widget_tag = Mustache.render(@tag.text, :default => question.default)
		when :toggle
		end

		puts Mustache.render(@tag.question, { :heading_tag => heading_tag, :query_tag => query_tag, :instruction_tag => instruction_tag, :widget_tag => widget_tag })

	end

	def convert_for_id(name)
		return '' if name == nil 

		return name.gsub(/\s/, '_')
	end

end