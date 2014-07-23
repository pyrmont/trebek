require './parser'

# Use the first argument as the path to the file to be parsed (abort if there is a problem).
abort "Error: Trebek requires the path of the file to be parsed to be passed as an argument." unless filename = ARGV[0]
abort "Error: Trebek could not find the file at the path you specified." unless File.exists? filename

# Get the contents of the file.
contents = IO.read(filename)

# Create the parser.
parser = Parser.new

# Parse the contents.
parsed_contents = parser.parse contents

# Print out the modified content.
puts parsed_contents