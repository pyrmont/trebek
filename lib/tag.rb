class Tag

	attr_accessor :survey_open, :survey_close, :group_open, :group_close, :table_open, :table_row, :table_close, :question, :heading, :query, :instruction, :label, :checkbox, :file, :radio, :select, :text_area, :text

	def initialize
		file = file = File.open('views/tags/_survey_open.mustache', 'rb')
		@survey_open = file.read
		file.close

		file = file = File.open('views/tags/_survey_close.mustache', 'rb')
		@survey_close = file.read
		file.close

		file = file = File.open('views/tags/_group_open.mustache', 'rb')
		@group_open = file.read
		file.close

		file = file = File.open('views/tags/_group_close.mustache', 'rb')
		@group_close = file.read
		file.close

		file = file = File.open('views/tags/_table_open.mustache', 'rb')
		@table_open = file.read
		file.close

		file = file = File.open('views/tags/_table_row.mustache', 'rb')
		@table_row = file.read
		file.close

		file = file = File.open('views/tags/_table_close.mustache', 'rb')
		@table_close = file.read
		file.close

		file = file = File.open('views/tags/_question.mustache', 'rb')
		@question = file.read
		file.close

		file = file = File.open('views/tags/_heading.mustache', 'rb')
		@heading = file.read
		file.close

		file = file = File.open('views/tags/_query.mustache', 'rb')
		@query = file.read
		file.close

		file = file = File.open('views/tags/_instruction.mustache', 'rb')
		@instruction = file.read
		file.close

		file = file = File.open('views/tags/_label.mustache', 'rb')
		@label = file.read
		file.close

		file = file = File.open('views/tags/_checkbox.mustache', 'rb')
		@checkbox = file.read
		file.close

		file = file = File.open('views/tags/_file.mustache', 'rb')
		@file = file.read
		file.close

		file = file = File.open('views/tags/_radio.mustache', 'rb')
		@radio = file.read
		file.close

		file = file = File.open('views/tags/_select.mustache', 'rb')
		@select = file.read
		file.close

		file = file = File.open('views/tags/_text_area.mustache', 'rb')
		@text_area = file.read
		file.close

		file = file = File.open('views/tags/_text.mustache', 'rb')
		@text = file.read
		file.close
	end

end