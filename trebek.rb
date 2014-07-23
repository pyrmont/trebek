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

# Parse out the questions.
questions = contents.scan /^(Q\.(\*)?\s+((?:(?!\n|{).)*)(?:{((?:(?!\n|}).)*)})?\n(?:!\s+((?:(?!\n\n).)*)\n)?(?:A.\s+)?((?:(?!\n\n).)*))/m

# Print out the questions.
questions.each do |question|
    puts question.inspect
end