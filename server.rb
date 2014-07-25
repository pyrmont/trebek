require 'sinatra'

get '/' do
    'Your mother.'
end

get '/survey' do
    send_file 'public/survey.index.html'
end