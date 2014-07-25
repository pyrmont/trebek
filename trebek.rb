require 'erb'
require './parser'

# Use the first argument as the path to the file to be parsed (abort if there is a problem).
abort "Error: Trebek requires the path of the file to be parsed to be passed as an argument." unless filename = ARGV[0]
abort "Error: Trebek could not find the file at the path you specified." unless File.exists? filename

# Get the contents of the file.
contents = File.read(filename)

# Create the parser.
parser = Parser.new

# Parse the contents.
@form = parser.parse contents

# Create the ERB renderer.
erb = ERB.new File.read('views/frame.erb')

# Set the title of the page.
@title = (ARGV[1]) ? ARGV[1] : 'Trebek Asks You the Questions!'

# Insert the parsed contents into the HTML template.
output = erb.result

# Print out the modified content.
puts output