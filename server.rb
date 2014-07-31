require 'sinatra'
require './library/processor'
require './library/database'

get '/' do
    'Your mother.'
end

get '/survey/completed' do
    'Well done!'
end

get '/survey/:id' do
    # Redirect to the no survey page if the file doesn't exist.
    redirect to('/error/existence') unless File.exists? 'built/survey_' + params[:id] + '.html'

    # Serve up the file.
    send_file 'built/survey_' + params[:id] + '.html'
end

post '/submit' do
    # Set the survey ID.
    redirect to('/error') unless survey_id = params[:survey_id]

    # Create the database
    database = Database.new './development/data/database.sqlite'

    # Process the form  and assign the hash {:answers, :message}.
    result = Processor.process database, survey_id, params

    case result[:message]
    when :no_survey
        # Redirect to the no survey page.
        redirect to('/error/existence')
    when :closed_survey
        # Redirect to the closed survey page.
        redirect to('/error/closed')
    when :answers_missing
        # Redirect back to the survey page.
        redirect to('/survey/' + survey_id)
    when :completed
        # Save the data in the database.
        database.save_response survey_id, result[:answers]

        # Redirect to the completed page.
        redirect to('/survey/completed')
    end
end

get '/error' do
    'There is a weird error. We will investigate.'
end