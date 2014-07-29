require 'sinatra'

get '/' do
    'Your mother.'
end

get '/survey/:id' do
    send_file 'built/survey_' + params[:id] + '.html'
end