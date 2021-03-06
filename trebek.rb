require 'data_mapper'
require 'sinatra'

require_relative 'lib/Parser'
require_relative 'lib/Renderer'

get '/' do
	'Your mother'
end

get '/examples/:file' do
	file = File.open('examples/' + params[:file] + '.txt', 'rb')
	data = file.read
	file.close

	@form = build data

	erb :frame
end

def build(data)
	parser = Parser.new
	parser.setup data
	surveys = parser.parse

	renderer = Renderer.new
	renderer.setup surveys
	renderer.render
end