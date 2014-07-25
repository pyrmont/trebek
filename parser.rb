require 'erb'

class Parser
    attr_reader :regex

    def initialize
        # Set up the regular expressions we'll use.
        @regex = {}
        @regex[:question] = /^(Q\.(\*)?\s+((?:(?!\n|{).)*)(?:{((?:(?!\n|}).)*)})?\n(?:!\s+((?:(?!\n).)*)\n)?(?:A.\s+)?((?:(?!\n\n).)*))/m
        @regex[:title] = /^((.*):\s+(.*))/
        @regex[:select] = /((?:-(\*|-)-)\s+((?:(?!-(?:\*|-)-).)*))/
        @regex[:radio] = /((?:\((\*| )\))\s+((?:(?!\((?:\*| )\)).)*))/
        @regex[:checkbox] = /((?:\[(\*| )\])\s+((?:(?!\[(?:\*| )\]).)*))/
        @regex[:area] = /(_{3,}\n_{3,}(?:\n_{3,})*)/m
        @regex[:line] = /(.*(_{3,})(?:\((.*)\))?.*)/

        # Set up the HTML tags we'll use.
        @html = {}
        @html[:question] = %{<div class="question <%= requirement_class %>"><%= question_text %></div>}
        @html[:instruction] = %{<div class="instruction"><%= instruction_text %></div>}
        @html[:answers] = %{<div class="answers"><%= answers %></div>}
        @html[:group] = %{<div><%= row_title %></div>}
        @html[:select] = %{<select id="<%= id_attribute %>" name="<%= name_attribute %>"><%= answers %></select>}
        @html[:option] = %{<option value="<%= answer_text %>" <%= selected_attribute %>><%= answer_text %></option>}
        @html[:checkradio] = %{<input id="<%= id_attribute + '_' + input_number.to_s %>" name="<%= name_attribute + optional_brackets %>" type="<%= answer_type.to_s %>" value="<%= answer_text %>" <%= selected_attribute %>><label for="<%= id_attribute + '_' + input_number.to_s %>"><%= answer_text %></label>}
        @html[:area] = %{<textarea id="<%= id_attribute %>" name="<%= name_attribute %>"></textarea>}
        @html[:line] = %{<input id="<%= id_attribute %>" name="<%= name_attribute %>" type="<%= type_attribute %>">}

        # Create separate ERB renderers for each tag.
        @tags = {}
        @html.each do |key, element|
            @tags[key] = ERB.new element
        end
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

            # Set the class name for whether the question must be answered or not.
            requirement_class = (requirement == '*') ? 'required' : ''

            # Set the HTML for the question.
            question_html = @tags[:question].result(binding)

            # Set the HTML for the instruction.
            instruction_html = (instruction_text) ? @tags[:instruction].result(binding) : ''

            # Parse and replace the group of answers or answers.
            answers = (is_group? answers) ? replace_group(answers, name_attribute, id_attribute) : replace_answers(answers, name_attribute, id_attribute)

            # Set the HTML for the answers.
            answers_html = @tags[:answers].result(binding)

            # Return the HTML.
            question_html + instruction_html + answers_html
        end
        return result
    end

    def replace_group(answers, name_attribute, id_attribute)
        row_number = 0
        answers.gsub! @regex[:title] do |row|
            # Increment the row number.
            row_number = row_number + 1

            # Assign meaningful variables for each captured group.
            row_title = $2
            row_answers = $3

            # Replace the rows with the appropriate HTML.
            row_answers = replace_answers row_answers, name_attribute + '[' + row_title.strip.downcase.gsub(/[[:punct:]]/, '').gsub(/\s+/, '_') + ']', id_attribute + '_' + row_number.to_s

            # Add the row answers to the title of the row.
            row_answers = @tags[:group].result(binding) + row_answers
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
                selected_attribute = (selected == '*') ? 'selected' : ''

                # Set the HTML for the answer.
                answer_html = @tags[:option].result(binding)
            end
            answers = @tags[:select].result(binding)
        when :radio, :checkbox
            input_number = 0
            answers.gsub! @regex[answer_type] do |answer|
                # Increment the input number.
                input_number = input_number + 1

                # Assign meaningful variables for each captured group.
                selected = $2
                answer_text = $3

                # Set the selected attribute.
                selected_attribute = (selected == '*') ? 'selected' : ''

                # Clean up the answer of any leading or trailing space.
                answer_text = answer_text.strip

                # Checkboxes need to use square brackets to identify the name.
                optional_brackets = (answer_type == :checkbox) ? '[]' : ''

                # Set the HTML for the answer.
                answer_html = @tags[:checkradio].result(binding)
            end
        when :area
            answers.gsub! @regex[answer_type] do |answer|
                answer_html = @tags[:area].result(binding)
            end
        when :line
            answers.gsub! @regex[answer_type] do |answer|
                # Assign meaningful variables for each captured group.
                line_delim = $2
                line_type = $3

                # Set the HTML for the input tag.
                type_attribute = (line_type) ? line_type.downcase : 'text'
                line_html = @tags[:line].result(binding)

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