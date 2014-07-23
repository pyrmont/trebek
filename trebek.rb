require './parser'

# Check that a parameter was passed.
if (ARGV.length < 1)
    abort "Error: Trebek requires the path of the file to be parsed to be passed as an argument."
end

# Get the filename based on the arguments used.
filename = ARGV[0]

# Get the contents of the file.
file = File.open(filename, 'r')
contents = file.read
file.close

# Create the parser.
parser = Parser.new

# Extract the questions from the contents.
questions = contents.scan parser.regex[:question]

# Print out the questions.
questions.each do |question|
    puts question.inspect
end

# Parse the contents.
parsed_contents = parser.parse contents

# Print out the modified content.
puts parsed_contents