require_relative 'Parser'

data = ''

File.open('surveys/simple.txt', 'r') do |survey|
	while line = survey.gets
        data += line
	end
end

parser = Parser.new
parser.setup data
parser.parse

# puts parser.inspect