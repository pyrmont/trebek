require 'sinatra'

get '/' do
    'Your mother.'
end

get '/survey' do
    send_file 'generated/survey.html'
end