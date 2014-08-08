require 'erb'
require './library/parser'
require './library/database'

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

# Parse the contents.
questions = Parser.parse contents

# Render the contents.
@questions = Parser.render contents, questions

# Create the database.
database = Database.new filename[:database]

# Set up the name of the survey.
survey_name = File.basename filename[:survey], '.*'

# Extract all the answers
all_answers = questions.collect{ |question| question.answers }.flatten

# Save the survey data.
@id = database.save_survey survey_name, all_answers

# Set the title of the page.
@title = 'Trebek Asks You the Questions!'

# Create the ERB renderer.
erb = ERB.new File.read('./templates/_frame.erb')

# Insert the parsed contents into the HTML template.
output = erb.result

# Save the output in the built/ folder using the survey_id.
File.open('./built/survey_' + @id.to_s + '.html', 'w') do |file|
    file.write output
end