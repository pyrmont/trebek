class Parser
    attr_reader :regex

    def initialize
        # Set up all the regular expressions we'll use.
        @regex = {}
        @regex[:question] = /^(Q\.(\*)?\s+((?:(?!\n|{).)*)(?:{((?:(?!\n|}).)*)})?\n(?:!\s+((?:(?!\n).)*)\n)?(?:A.\s+)?((?:(?!\n\n).)*))/m
        @regex[:title] = /^((.*):\s+(.*))/
        @regex[:select] = /((?:-(\*|-)-)\s+((?:(?!-(?:\*|-)-).)*))/
        @regex[:radio] = /((?:\((\*| )\))\s+((?:(?!\((?:\*| )\)).)*))/
        @regex[:checkbox] = /((?:\[(\*| )\])\s+((?:(?!\[(?:\*| )\]).)*))/
        @regex[:area] = /(_{3,}\n_{3,}(?:\n_{3,})*)/m
        @regex[:line] = /(.*(_{3,})(?:\((.*)\))?.*)/
    end

    def parse(contents)
        # Parse and replace the questions.
        result = replace_questions contents
        return result
    end

    def replace_questions(contents)
        # Questions begin at 0 because we increment as soon as we enter the block.
        question_number = 0
        result = contents.gsub @regex[:question] do |question|
            # Increment the question number.
            question_number = question_number + 1

            # Assign meaningful variables for each captured group.
            requirement = $2
            question_text = $3
            name_attribute = $4
            instruction_text = $5
            answers = $6

            # Check the name attribute is set and if not use the incremented generic name.
            name_attribute = (name_attribute) ? name_attribute : 'question_' + question_number.to_s

            # Set the ID attribute to be equal to the name_attribute.
            id_attribute = name_attribute

            # Create an empty hash for the HTML.
            html = {}

            # Set the class name for whether the question must be answered or not.
            requirement_class = (requirement == '*') ? ' required' : ''

            # Set the HTML for the question.
            html[:question] = '<div class="question' + requirement_class + '">' + question_text + '</div>'

            # Set the HTML for the instruction.
            html[:instruction] = (instruction_text) ? '<div class="instruction">' + instruction_text + '</div>' : ''

            # Parse and replace the group of answers or answers.
            if is_group? answers
                answers = replace_group answers, name_attribute, id_attribute
            else
                answers = replace_answers answers, name_attribute, id_attribute
            end

            # Set the HTML for the answers.
            html[:answers] = '<div class="answers">' + answers + '</div>'

            # Return the HTML.
            html[:question] + html[:instruction] + html[:answers]
        end
        return result
    end

    def replace_group(answers, name_attribute, id_attribute)
        row_number = 0
        answers.gsub! @regex[:title] do |row|
            row_number = row_number + 1
            # Assign meaningful variables for each captured group.
            row_title = $2
            row_answers = $3
            row_answers = replace_answers row_answers, name_attribute + '[' + row_title.strip.downcase.gsub(/[[:punct:]]/, '').gsub(/\s+/, '_') + ']', id_attribute + '_' + row_number.to_s
            row_answers = '<div>' + row_title + '</div>' + row_answers
        end
        return answers
    end

    def replace_answers(answers, name_attribute, id_attribute)
        answer_type = get_type answers
        case answer_type
        when :select
            answers.gsub! @regex[answer_type] do |answer|
                # Assign meaningful variables for each captured group.
                selected = $2
                answer_text = $3

                # Set the selected attribute.
                selected_attribute = (selected == '*') ? ' selected' : ''

                # Set the HTML for the answer.
                answer_html = '<option value="' + answer_text + '"' + selected_attribute + '>' + answer_text + '</option>'
            end
            answers = '<select id="' + id_attribute + '" name="' + name_attribute + '">' + answers + '</select>'
        when :radio, :checkbox
            input_number = 0
            answers.gsub! @regex[answer_type] do |answer|
                # Increment the input number
                input_number = input_number + 1
                # Assign meaningful variables for each captured group.
                selected = $2
                answer_text = $3

                # Set the selected attribute.
                selected_attribute = (selected == '*') ? ' selected' : ''

                # Clean up the answer of any leading or trailing space.
                answer_text = answer_text.strip

                # Checkboxes need to use square brackets to identify the name.
                optional_brackets = (answer_type == :checkbox) ? '[]' : ''

                # Set the HTML for the answer.
                answer_html = '<input id="' + id_attribute + '_' + input_number.to_s + '" name="' + name_attribute + optional_brackets + '" type="' + answer_type.to_s + '" value="' + answer_text + '"' + selected_attribute + '><label for="' + id_attribute + '_' + input_number.to_s + '">' + answer_text + '</label>'
            end
        when :area
            answers.gsub! @regex[answer_type] do |answer|
                answer_html = '<textarea id="' + id_attribute + '" name="' + name_attribute + '"></textarea>'
            end
        when :line
            answers.gsub! @regex[answer_type] do |answer|
                # Assign meaningful variables for each captured group.
                line_delim = $2
                line_type = $3

                # Set the HTML for the input tag.
                type_attribute = (line_type) ? line_type.downcase : 'text'
                line_html = '<input id="' + id_attribute + '" name="' + name_attribute + '" type="' + type_attribute + '">'

                # Set the HTML for the answer.
                line_replace = (line_type) ? line_delim + '(' + line_type + ')' : line_delim
                answer_html = answer.gsub(line_replace, line_html)
            end
        end

        return answers
    end

    def is_group?(answers)
        return answers.scan(@regex[:title]).length > 0
    end

    def get_type(answers)
        type = { :select => '-', :radio => '(', :checkbox => '['}.key answers[0]
        if type
            return type
        elsif answers.scan(@regex[:area]).length > 0
            return :area
        elsif answers.scan(@regex[:line]).length > 0
            return :line
        end
    end

end