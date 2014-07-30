require 'sinatra'
require './library/processor'

get '/' do
    'Your mother.'
end

get '/survey/:id' do
    send_file 'built/survey_' + params[:id] + '.html'
end

post '/submit' do
    # Create the processor
    processor = Processor.new './development/data/database.sqlite'

    # Process the form with message :no_survey, :closed_survey, :answers_missing or :completed.
    message = processor.process '1', params
    case message
    when :no_survey
        # Redirect to the no survey page.
    when :closed_survey
        # Redirect to the closed survey page.
    when :answers_missing
        # Redirect to the survey page.
    when :completed
        # Redirect to the completed page.
    end
end