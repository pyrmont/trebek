class Group

	attr_accessor :type, :name, :parent, :position

	def initialize(open_or_close)
		@type = open_or_close
	end

end