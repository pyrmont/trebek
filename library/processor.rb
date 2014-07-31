module Processor

    extend self

    def process(database, survey_id, params)
        # Return if the survey doesn't exist.
        return { :answers => {}, :message => :no_survey } unless database.survey_exists? survey_id

        # Return if the survey is closed.
        return { :answers => {}, :message => :closed_survey } unless database.survey_open? survey_id

        # Get the answer metadata for this survey.
        possible_answers = database.get_possible_answers survey_id

        # Get the relevant answers for this survey from the submitted data.
        result = extract_answers possible_answers, params
        answers = result[:answers]
        required = result[:required]

        # Return nil if required answers were missing.
        return { :answers => answers, :message => :answers_missing } if required[:uncompleted].count > 0

        # Return the answers if form processed successfully.
        return { :answers => answers, :message => :completed }
    end

    private

        def extract_answers(possible_answers, params)
            # Create an empty hash.
            answers = {}

            # Create a hash holding an array for required questions that are completed and required questions that are uncompleted.
            required = { :completed => [], :uncompleted => [] }

            # Save the submitted answers per each possible answer.
            possible_answers.each do |possible_answer|
                # Check if the answer_name is part of an array (indicated in the database by the use of square brackets).
                is_answer_array = (possible_answer[:answer_name].index(/\[(?:.+)\]/)) ? true : false

                if is_answer_array
                    # Get the base answer name.
                    base = possible_answer[:answer_name].gsub(/(\[(?:[^\[]+)\])/, '')

                    # Get the names for each dimension of the array (the second dimension may be nil).
                    dimensions = possible_answer[:answer_name].scan(/(?:\[([^\[\]]+)\])/)
                    first_d = (dimensions[0][0] && dimensions[0][0].match(/^\d+$/)) ? dimensions[0][0].to_i : dimensions[0][0]
                    second_d = (dimensions[1]) ? dimensions[1][0] : nil
                    second_d = (second_d && second_d.match(/^\d+$/)) ? second_d.to_i : second_d

                    # Assign the value based on whether the second dimension exists.
                    if first_d && second_d
                        value = (params[base] == nil || params[base][first_d] == nil || params[base][first_d][second_d] == nil || params[base][first_d][second_d].empty?) ? nil : params[base][first_d][second_d]
                    elsif first_d
                        value = (params[base] == nil || params[base][first_d] == nil || params[base][first_d].empty?) ? nil : params[base][first_d]
                    end

                    # Get the base answer name.
                    base_name = possible_answer[:answer_name].gsub(/(\[(?:[^\[]+)\])/, '')
                    answer_array_name = base_name + '[]'

                    # Get the names for each dimension of the array (the second dimension may be nil).
                    dimensions = possible_answer[:answer_name].scan(/(?:\[([^\[\]]+)\])/)
                    first_d = (dimensions[0][0] && dimensions[0][0].match(/^\d+$/)) ? dimensions[0][0].to_i : dimensions[0][0]
                    second_d = (dimensions[1]) ? dimensions[1][0] : nil
                    second_d = (second_d && second_d.match(/^\d+$/)) ? second_d.to_i : second_d

                    # Assign the value based on whether the second dimension exists.
                    if first_d && second_d
                        value = (params[base_name] == nil || params[base_name][first_d] == nil || params[base_name][first_d][second_d] == nil || params[base_name][first_d][second_d].empty?) ? nil : params[base_name][first_d][second_d]
                    elsif first_d
                        value = (params[base_name] == nil || params[base_name][first_d] == nil || params[base_name][first_d].empty?) ? nil : params[base_name][first_d]
                    end
                else
                    value = (params[possible_answer[:answer_name]] == nil || params[possible_answer[:answer_name]].empty?) ? nil : params[possible_answer[:answer_name]]
                end

                # If a value was submitted with the response, save it to the answers hash.
                answers[possible_answer[:answer_name]] = value if value

                # If the question is required, store the question in the appropriate array.
                if possible_answer[:required]
                    if value
                        if is_answer_array && !(required[:completed].include? answer_array_name)
                            required[:completed].push answer_array_name
                            required[:uncompleted].delete answer_array_name
                        end
                    else
                        if is_answer_array
                            required[:uncompleted].push answer_array_name unless required[:completed].include? answer_array_name
                        else
                            required[:uncompleted].push possible_answer[:answer_name]
                        end
                    end
                end
            end

            return { :answers => answers, :required => required }
        end
end