require_relative 'lib/Parser'

data = ''

File.open('surveys/simple.names.txt', 'r') do |survey|
	while line = survey.gets
        data += line
	end
end

parser = Parser.new
parser.setup data
surveys = parser.parse

puts surveys.inspect

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
surveys = parser.parse

puts surveys.inspect

# Reset data
puts "\n\n"
data = ''

File.open('surveys/complex.txt', 'r') do |survey|
	while line = survey.gets
        data += line
	end
end

parser = Parser.new
parser.setup data
surveys = parser.parse

puts surveys.inspect