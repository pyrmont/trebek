require_relative 'Parser'

data = ''

File.open('surveys/simple.names.txt', 'r') do |survey|
	while line = survey.gets
        data += line
	end
end

parser = Parser.new
parser.setup data
parser.parse

# Reset data
puts "\n\n"
data = ''

File.open('surveys/simple.nonames.txt', 'r') do |survey|
	while line = survey.gets
        data += line
	end
end

parser = Parser.new
parser.setup data
parser.parse

# puts parser.inspect