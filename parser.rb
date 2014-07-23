class Parser
    attr_reader :regex

    def initialize
        # Set up all the regular expressions we'll use.
        @regex = {}
        @regex[:question] = /^(Q\.(\*)?\s+((?:(?!\n|{).)*)(?:{((?:(?!\n|}).)*)})?\n(?:!\s+((?:(?!\n\n).)*)\n)?(?:A.\s+)?((?:(?!\n\n).)*))/m
        @regex[:title] = /^(.*):\s+(.*)/
        @regex[:select] = /((?:-(\*|-)-)\s+((?:(?!-(?:\*|-)-).)*))/
        @regex[:radio] = /((?:\((\*| )\))\s+((?:(?!\((?:\*| )\)).)*))/
        @regex[:checkbox] = /((?:\[(\*| )\])\s+((?:(?!\[(?:\*| )\]).)*))/
        @regex[:line] = /(.*(_{3,})(?:\((.*)\))?.*)/
        @regex[:area] = /(_{3,}\n_{3,}(?:\n_{3,})*)/m

        # Create an array for the regular expressions of potential answers.
        @regex[:answers] = [regex[:title], regex[:select], regex[:radio], regex[:checkbox], regex[:line], regex[:area]]
    end

    def parse(contents)
        # Parse and replace the questions.
        result = replace_questions contents
        return result
    end

    def replace_questions(contents)
        result = contents.gsub @regex[:question] do |question|
            # Assign meaningful variables for each captured group.
            requirement = $2
            question_text = $3
            name_attribute = $4
            instruction_text = $5
            answers = $6

            # Create an empty hash for the HTML.
            html = {}

            # Set the class name for whether the question must be answered or not.
            requirement_class = (requirement == '*') ? ' required' : ''

            # Set the HTML for the question.
            html[:question] = '<div class="question' + requirement_class + '">' + question_text + '</div>'

            # Set the HTML for the instruction.
            html[:instruction] = (instruction_text) ? '<div class="instruction">' + instruction_text + '</div>' : ''

            # Parse and replace the answers.
            answers = replace_answers answers

            # Set the HTML for the answers.
            html[:answers] = '<div class="answers">' + answers + '</div>'

            # Return the HTML.
            html[:question] + html[:instruction] + html[:answers]
        end
        return result
    end

    def replace_answers(answers)
        @regex[:answers].each do |re|
            answers.gsub! re do |answer|
                # Perform different substitutions depending on the type of answer.
                case @regex.key re
                when :title
                when :select
                when :radio
                when :checkbox
                    # Assign meaningful variables for each captured group.
                    selected = $2
                    answer_text = $3

                    # Set the selected attribute.
                    selected_attribute = (selected == '*') ? ' selected' : ''

                    # Escape answer_text so that it's safe to use as in the value attribute of an input element.
                    answer_text = answer_text.strip.downcase.gsub(/\s+/, '_')

                    # Set the HTML for the answer.
                    answer_html = '<input type="checkbox" value="' + answer_text + '"' + selected_attribute + '>'
                when :line
                    # Assign meaningful variables for each captured group.
                    line_delim = $2
                    line_type = $3

                    # Set the HTML for the input tag.
                    type_attribute = (line_type) ? line_type.downcase : 'text'
                    line_html = '<input type="' + type_attribute + '">'

                    # Set the HTML for the answer.
                    line_replace = (line_type) ? line_delim + '(' + line_type + ')' : line_delim
                    answer_html = answer.gsub(line_replace, line_html)
                when :area
                end
            end
        end
        return answers
    end

end