require_relative 'lib/Parser'
require_relative 'lib/Renderer'

data = ''

File.open('surveys/simple.names.txt', 'r') do |survey|
	while line = survey.gets
        data += line
	end
end

parser = Parser.new
parser.setup data
surveys = parser.parse

renderer = Renderer.new
renderer.setup surveys
renderer.render