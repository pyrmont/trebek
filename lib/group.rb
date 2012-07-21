# The group object functions more as a quasi-object that closely approximates a div tag (ie. it has separate opening and closing types).

class Group

	attr_accessor :type, :name, :parent, :position

	def initialize(open_or_close)
		@type = open_or_close
	end

end