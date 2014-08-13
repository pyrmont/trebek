require 'erb'
require 'redcarpet'

module Parser

    extend self

    Question = Struct.new :name, :text, :instruction, :required, :answers
    Answer = Struct.new :name, :type, :text, :question, :required, :title, :format, :selected, :delim

    @@regex = {
        :question       => /^(Q\.(\*)?\s+((?:(?!\n|{).)*)(?:{((?:(?!\n|}).)*)})?\n(?:!\s+((?:(?!\n).)*)\n)?(?:A.\s+)?((?:(?!\n\n).)*))/m,
        :row            => /^((.*):\s+(.*))/,
        :select         => /((?:-(\*|-)-)\s+((?:(?!-(?:\*|-)-).)*))/,
        :radio          => /((?:\((\*| )\))\s+((?:(?!\((?:\*| )\)).)*))/,
        :checkbox       => /((?:\[(\*| )\])\s+((?:(?!\[(?:\*| )\]).)*))/,
        :area           => /(_{3,}\n_{3,}(?:\n_{3,})*)/m,
        :line           => /(.*(_{3,})(?:\((.*)\))?.*)/
    }

    @@html = {
        :question       => %{<div class="question <%= requirement_class %>"><%= question_formatted %></div>},
        :instruction    => %{<div class="instruction"><%= instruction_formatted %></div>},
        :answers        => %{<div class="answers"><%= answers_formatted %></div>},
        :row            => %{<div class="row"><div class="title"><%= title_formatted %></div><div><%= row_formatted %></div></div>},
        :select         => %{<select id="<%= id_attribute %>" name="<%= name_attribute %>"><%= answers_formatted %></select>},
        :option         => %{<option value="<%= answer_text %>" <%= selected_attribute %>><%= answer_text %></option>},
        :radio          => %{<input id="<%= id_attribute %>" name="<%= name_attribute %>" type="radio" value="<%= answer_text %>" <%= selected_attribute %>><label for="<%= id_attribute %>"><%= answer_formatted %></label>},
        :checkbox       => %{<input id="<%= id_attribute %>" name="<%= name_attribute %>" type="checkbox" value="<%= answer_text %>" <%= selected_attribute %>><label for="<%= id_attribute %>"><%= answer_formatted %></label>},
        :area           => %{<textarea id="<%= id_attribute %>" name="<%= name_attribute %>"></textarea>},
        :line           => %{<input id="<%= id_attribute %>" name="<%= name_attribute %>" type="<%= type_attribute %>">}
    }

    @@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(options = {}), extensions = {})

    def parse(contents)
        # Create an empty array.
        questions = []

        # Set the question number.
        question_number = 1

        contents.scan @@regex[:question] do |match|
            # Assign meaningful variables for each captured group.
            c = { :requirement => $2, :question_text => $3, :name_attribute => $4, :instruction_text => $5, :answers_text => $6 }

            # Create an instance of the question struct.
            question = Question.new

            # Set the question text and the instuction text.
            question.text = c[:question_text]
            question.instruction = c[:instruction_text]

            # Set the name attribute is set and if not use the incremented generic name.
            question.name = (c[:name_attribute]) ? c[:name_attribute] : 'answer_' + question_number.to_s

            # Set whether the question is required.
            question.required = (c[:requirement] == '*') ? true : false

            # Parse and replace the group of answers or answers.
            question.answers = parse_answers c[:answers_text], question

            # Push the question struct onto the questions array.
            questions.push question

            # Increment the question number.
            question_number = question_number + 1
        end

        # Return the questions.
        questions
    end

    def render(contents, questions)
        # Set the tags.
        tags = {}
        @@html.each do |key, element|
            tags[key] = ERB.new element
        end

        # Set the counter.
        counter = 0

        contents.gsub! @@regex[:question] do |match|
            # Set the question.
            question = questions[counter]

            # Replace the question. Replace the instruction. Replace the answers.
            question_html = replace_question question, tags
            instruction_html = replace_instruction question, tags
            answers_html = replace_answers question, tags

            # Increment the counter.
            counter = counter + 1

            # Return the replaced text.
            question_html + instruction_html + answers_html
        end

        # Return the replaced contents.
        convert_markdown contents, false
    end

    private

        def parse_answers(contents, question, level = 0, title = nil)
            # Create an empty array.
            answers = []

            # Check if we are in a group only if level is zero (otherwise we're already in a group).
            answers = parse_group contents, question, level if level == 0

            # If answers is non-empty, we can return.
            return answers if answers.count > 0

            case get_answer_type contents
            when :select
                answers = parse_select contents, question, level, title
            when :radio
                answers = parse_radio contents, question, level, title
            when :checkbox
                answers = parse_checkbox contents, question, level, title
            when :area
                answers = parse_area contents, question, level, title
            when :line
                answers = parse_line contents, question, level, title
            end

            # Return the answers.
            answers
        end

        def parse_group(contents, question, level = 0)
            # Create an empty array.
            answers = []

            # Increment the level.
            level = level + 1

            # Set the row number.
            row_number = 0

            contents.scan @@regex[:row] do |row|
                # Assign meaningful variables for each captured group.
                c = { :title => $2, :answers_text => $3 }

                # Concatenate the array onto the existing array.
                answers.concat(parse_answers c[:answers_text], question, level, c[:title])

                # Increment the row number.
                row_number = row_number + 1
            end

            # Return the answers.
            answers
        end

        def parse_select(contents, question, level, title)
            # There's no fundamental difference between select, radio and checkbox so handle it in a helper method.
            parse_selectable contents, question, level, title, :select
        end

        def parse_radio(contents, question, level, title)
            # There's no fundamental difference between select, radio and checkbox so handle it in a helper method.
            parse_selectable contents, question, level, title, :radio
        end

        def parse_checkbox(contents, question, level, title)
            # There's no fundamental difference between select, radio and checkbox so handle it in a helper method.
            parse_selectable contents, question, level, title, :checkbox
        end

        def parse_area(contents, question, level, title)
            # Create an empty array.
            answers = []

            contents.scan @@regex[:area] do |match|
                # Create an instance of the answer struct.
                answer = Answer.new

                # Set the name based on the level.
                answer.name = get_answer_name question.name, level, title

                # Set the answer type, answer text, question text, mandatoriness, answer title and answer format.
                answer.type = :area
                answer.question = question.text
                answer.required = question.required
                answer.title = title
                answer.format = 'Text'

                # Push the answer struct onto the answers array.
                answers.push answer
            end

            # Return the answers.
            answers
        end

        def parse_line(contents, question, level, title)
            # Create an empty array.
            answers = []

            contents.scan @@regex[:line] do |match|
                # Assign meaningful variables for each captured group.
                c = { :text => $1, :delim => $2, :format => $3 }

                # Create an instance of the answer struct.
                answer = Answer.new

                # Set the name based on the level.
                answer.name = get_answer_name question.name, level, title

                # Set the answer type, answer text, question text, mandatoriness, answer title and answer format.
                answer.type = :line
                answer.text = c[:text].strip
                answer.question = question.text
                answer.required = question.required
                answer.title = title
                answer.format = (c[:format]) ? c[:format] : 'Text'
                answer.delim = c[:delim]

                # Push the answer struct onto the answers array.
                answers.push answer
            end

            # Return the answers.
            answers
        end

        def parse_selectable(contents, question, level, title, type)
            # Create an empty array.
            answers = []

            # Set the input number.
            input_number = 0

            contents.scan @@regex[type] do |match|
                # Assign meaningful variables for each captured group.
                c = { :selected => $2, :text => $3 }

                # Create an instance of the answer struct.
                answer = Answer.new

                # Set the name based on the level.
                answer.name = get_answer_name question.name, level, title

                # If this is a checkbox, there can be multiple values so add the input_number to the name.
                answer.name = (type == :checkbox) ? answer.name + '[' + input_number.to_s + ']' : answer.name

                # Set the answer type, answer text, question text, mandatoriness, answer title and answer format.
                answer.type = type
                answer.text = c[:text].strip
                answer.question = question.text
                answer.required = question.required
                answer.title = title
                answer.format = 'Text'

                # Set the selected attribute.
                answer.selected = (c[:selected] == '*') ? true : false

                # Push the answer struct onto the answers array.
                answers.push answer

                # Increment the input number.
                input_number = input_number + 1
            end

            # Return the answers.
            answers
        end

        def replace_questions(contents, questions)
            # Set the tags.
            tags = {}
            @@html.each do |key, element|
                tags[key] = ERB.new element
            end

            # Set the counter.
            counter = 0

            contents.gsub! @@regex[:question] do |match|
                # Set the question.
                question = questions[counter]

                # Replace the question. Replace the instruction. Replace the answers.
                question_html = replace_question question, tags
                instruction_html = replace_instruction question, tags
                answers_html = replace_answers question, tags

                # Increment the counter.
                counter = counter + 1

                # Return the replaced text.
                question_html + instruction_html + answers_html
            end

            # Return the replaced contents.
            contents
        end

        def replace_question(question, tags)
            # Format the question.
            question_formatted = convert_markdown question.text

            # Set whether the question is required.
            requirement_class = (question.required) ? 'required' : ''

            # Set the HTML.
            question_html = tags[:question].result(binding)
        end

        def replace_instruction(question, tags)
            # Format the instruction.
            instruction_formatted = convert_markdown question.instruction

            # Set the HTML.
            instruction_html = tags[:instruction].result(binding)
        end

        def replace_answers(question, tags)
            # Set an empty string for the answers.
            answers_formatted = ''

            # If group, return answers_html.
            return replace_group(question, tags) if get_question_type(question) == :group

            case get_question_type question
            when :select
                answers_formatted = replace_select question, tags, question.answers
            when :radio
                answers_formatted = replace_radio question, tags, question.answers
            when :checkbox
                answers_formatted = replace_checkbox question, tags, question.answers
            when :area
                answers_formatted = replace_area question, tags, question.answers
            when :line
                answers_formatted = replace_line question, tags, question.answers
            end

            # Set the HTML.
            answers_html = tags[:answers].result(binding)
        end

        def replace_group(question, tags)
            # Create an empty string for the answers.
            answers_formatted = ''

            # Put the answers into rows.
            rows = get_rows question.answers

            # Create an empty string for the row.
            row_formatted = ''

            rows.each do |row|
                # Format the title.
                title_formatted = convert_markdown row[0].title

                case row[0].type
                when :radio
                    row_formatted = replace_radio question, tags, row
                when :checkbox
                    row_formatted = replace_checkbox question, tags, row
                when :line
                    row_formatted = replace_line question, tags, row
                end

                # Set the HTML.
                row_html = tags[:row].result(binding)

                # Add the HTML to the answers_formatted variable.
                answers_formatted = answers_formatted + row_html
            end

            # Set the HTML.
            answers_html = tags[:answers].result(binding)
        end

        def replace_select(question, tags, answers)
            # Create an empty string.
            answers_formatted = ''

            # Create empty name and ID attributes.
            name_attribute = ''
            id_attribute = ''

            answers.each do |answer|
                # Set the variables for the ERB renderer.
                id_attribute = get_id_attribute answer.name
                name_attribute = answer.name
                selected_attribute = (answer.selected) ? 'selected' : ''
                answer_text = answer.text

                # Format the option element.
                option_formatted = tags[:option].result(binding)

                # Add the option element to the other elements.
                answers_formatted = answers_formatted + option_formatted
            end

            # Format and return the answers.
            answers_formatted = tags[:select].result(binding)
        end

        def replace_radio(question, tags, answers)
            # There's no fundamental difference between radio and checkbox so use a helper method.
            replace_selectable question, tags, answers
        end

        def replace_checkbox(question, tags, answers)
            # There's no fundamental difference between radio and checkbox so use a helper method.
            replace_selectable question, tags, answers
        end

        def replace_area(question, tags, answers)
            # Create an empty string.
            answers_formatted = ''

            answers.each do |answer|
                # Set the variables for the ERB renderer.
                name_attribute = answer.name
                id_attribute = get_id_attribute answer.name

                # Format the area element.
                area_formatted = tags[:area].result(binding)

                # Add the area element to the other elements.
                answers_formatted = answers_formatted + area_formatted
            end

            # Return the answers (there should only be one).
            answers_formatted
        end

        def replace_line(question, tags, answers)
            # Create an empty string.
            answers_formatted = ''

            answers.each do |answer|
                # Set the variables for the ERB renderer.
                name_attribute = answer.name
                id_attribute = get_id_attribute answer.name
                type_attribute = answer.format.downcase

                # Format the line element.
                line_formatted = tags[:line].result(binding)

                # Format the answer.
                answer_formatted = convert_markdown(answer.text.gsub answer.delim, line_formatted)

                # Add the area element to the other elements.
                answers_formatted = answers_formatted + answer_formatted
            end

            # Return the answers (there should only be one).
            answers_formatted
        end

        def replace_selectable(question, tags, answers)
            # Create an empty string.
            answers_formatted = ''

            # Set the input_number.
            input_number = 0

            answers.each do |answer|
                # Set the variables for the ERB renderer.
                case answer.type
                when :radio
                    name_attribute = answer.name
                    id_attribute = get_id_attribute(answer.name) + '_' + input_number.to_s
                when :checkbox
                    name_attribute = answer.name.gsub(/(\[((?:\d)*)\]$)/, '[]')
                    id_attribute = get_id_attribute(answer.name)
                end
                selected_attribute = (answer.selected) ? 'selected' : ''
                answer_text = answer.text
                answer_formatted = convert_markdown answer.text

                # Format the radio/checkbox element.
                selectable_formatted = tags[answer.type].result(binding)

                # Add the radio/checkbox element to the other elements.
                answers_formatted = answers_formatted + selectable_formatted

                # Increment the counter.
                input_number = input_number + 1
            end

            # Return the answers.
            answers_formatted
        end

        def get_answer_name(question_name, level, title)
            answer_name = (level > 0) ? question_name + '[' + title.strip.downcase.gsub(/[[:punct:]]/, '').gsub(/\s+/, '_') + ']' : question_name
        end

        def get_answer_type(contents)
            # Select the input type based on the first character in the contents. If not one of the three, type will be nil.
            type = { :select => '-', :radio => '(', :checkbox => '['}.key contents[0]
            return type if type

            # If type is nil, decide if this is a text area or a text field.
            if contents.scan(@@regex[:area]).length > 0
                return :area
            elsif contents.scan(@@regex[:line]).length > 0
                return :line
            end
        end

        def get_question_type(question)
            # Get an answer.
            answer = question.answers[0]

            # Return :group if there is a title.
            return :group if answer.title

            # Otherwise return the type.
            answer.type
        end

        def get_rows(answers)
            # Create a nil object for the previous title.
            previous_title = nil

            # Create an empty array.
            rows = []
            row = []

            answers.each do |answer|
                if previous_title && previous_title != answer.title
                    # Add this row to the rows.
                    rows.push row

                    # Reset the array.
                    row = []
                end

                # Add the answer to this row.
                row.push answer

                # Set the previous_title to be the current title.
                previous_title = answer.title
            end

            # Push the final row onto the end.
            rows.push row
        end

        def get_id_attribute(name_attribute)
            # Replace [something] with _something.
            id_attribute = name_attribute.gsub /(\[((?:\w)*)\])/ do |match|
                # Assign meaningful variables to the captured group.
                without_brackets = $2

                # Replace the term in brackets with the term preceded by an underscore.
                '_' + without_brackets
            end
        end

        def convert_markdown(text, inline = true)
            # If there is no text, return.
            return text unless text

            # Render the text.
            text = @@markdown.render text

            # Remove the paragraph tags if this is an inline conversion.
            text = (inline) ? text.gsub(/^<p>/, '').gsub(/<\/p>$/, '') : text
        end
end