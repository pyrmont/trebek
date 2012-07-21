class Question

	attr_accessor :required, :type, :heading, :query, :instruction, :default, :answers, :selected

	def initialize
		@answers = []
	end
end