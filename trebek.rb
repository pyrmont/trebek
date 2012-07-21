require_relative 'lib/Parser'
require_relative 'lib/Renderer'

file = File.open("surveys/complex.txt", "rb")
data = file.read
file.close

parser = Parser.new
parser.setup data
surveys = parser.parse

renderer = Renderer.new
renderer.setup surveys
form = renderer.render

puts form