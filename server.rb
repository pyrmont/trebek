require 'sinatra'
require './library/processor'

get '/' do
    'Your mother.'
end

get '/survey/:id' do
    # Redirect to the no survey page if the file doesn't exist.
    redirect to('error/existence') unless File.exists? 'built/survey_' + params[:id] + '.html'

    # Serve up the file.
    send_file 'built/survey_' + params[:id] + '.html'
end

post '/submit' do
    # Set the survey ID.
    redirect to('/error') unless survey_id = params[:survey_id]

    # Create the processor
    processor = Processor.new './development/data/database.sqlite'

    # Process the form with message :no_survey, :closed_survey, :answers_missing or :completed.
    message = processor.process survey_id, params
    case message
    when :no_survey
        # Redirect to the no survey page.
        redirect to('/error/existence')
    when :closed_survey
        # Redirect to the closed survey page.
        redirect to('error/closed')
    when :answers_missing
        # Redirect to the survey page.
        redirect to('survey/' + survey_id)
    when :completed
        # Redirect to the completed page.
        redirect to('survey/complete')
    end
end

get '/error' do
    'There is a weird error. We will investigate.'
end