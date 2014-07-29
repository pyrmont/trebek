require 'erb'
require 'sequel'
require './library/parser'

# Create an empty hash.
filename = {}

# Use the first argument as the path to the survey file (abort if there is a problem).
abort "Error: Trebek requires the path of the survey file as the first argument." unless filename[:survey] = ARGV[0]
abort "Error: Trebek could not find the survey file you specified." unless File.exists? filename[:survey]

# Use the second argument as the path to the database file (abort if there is a problem).
abort "Error: Trebek requires the path of the database as the second argument." unless filename[:database] = ARGV[1]
abort "Error: Trebek could not find the database file you specified." unless File.exists? filename[:database]

# Get the contents of the file.
contents = File.read(filename[:survey])

# Create the parser.
parser = Parser.new

# Parse the contents.
@survey = parser.parse contents

# Set the title of the page.
@title = 'Trebek Asks You the Questions!'

# Create the ERB renderer.
erb = ERB.new File.read('./views/frame.erb')

# Insert the parsed contents into the HTML template.
output = erb.result

# Save the output in generated/survey.html.
File.open('./generated/survey.html', 'w') do |file|
    file.write output
end

# Get the answers that were parsed.
answers = parser.answers

# Open the database.
database = Sequel.sqlite filename[:database]

# Create the survey table.
database.create_table :surveys do
    primary_key :id
    String :name, :text=> true
    TrueClass :open
end

# Insert the details about this survey into the table.
surveys_table = database[:surveys]
surveys_table.insert :name => 'Survey', :open => false

# Create the table for the answer metadata.
database.create_table :survey_1_metadata do
    primary_key :id
    foreign_key :survey_id, :surveys
    String :answer_name, :text => true
    String :answer_text, :text => true
    String :question_text, :text => true
    String :title_text, :text => true
    String :format, :text => true
    TrueClass :required
    TrueClass :current
end

# Insert the metadata for each answer into the table.
metadata_table = database[:survey_1_metadata]
answers.each do |answer|
    metadata_table.insert :survey_id => 1, :answer_name => answer.answer_id, :answer_text => answer.answer_text, :question_text => answer.question_text, :title_text => answer.title_text, :format => answer.format, :required => answer.required?, :current => true
end

# Create the table for the answer responses.
database.create_table :survey_1_responses do
    primary_key :id
    foreign_key :survey_id, :surveys
    String :session, :text => true
    answers.each do |answer|
        String answer.answer_id, :text => true
    end
end