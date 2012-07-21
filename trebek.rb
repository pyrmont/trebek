require 'data_mapper'
require 'sinatra'

require_relative 'lib/Parser'
require_relative 'lib/Renderer'

get '/' do
	'Your mother'
end

get '/examples/:file' do
	file = File.open('surveys/' + params[:file] + '.txt', 'rb')
	data = file.read
	file.close

	build data
end

def build(data)
	parser = Parser.new
	parser.setup data
	surveys = parser.parse

	renderer = Renderer.new
	renderer.setup surveys
	form = renderer.render
end