require 'sequel'

class Processor

    attr_reader :required

    def initialize(filename)
        # Create an empty array.
        @required = []

        # Open the @store.
        @store = Sequel.sqlite filename
    end

    def process(survey_id, params)
        # Create the survey table.
        surveys_table = @store[:surveys]

        # Return a symbol if the survey doesn't exist.
        return :no_survey if surveys_table.where(:id => survey_id).count == 0

        # Return a symbol if the survey is closed.
        return :closed_survey if surveys_table.where(:id => survey_id).get(:open) == false

        # Set the name of the tables.
        metadata_name = ('survey_' + survey_id + '_metadata').to_sym
        responses_name = ('survey_' + survey_id + '_responses').to_sym

        # Create the metadata table.
        metadata_table = @store[metadata_name]

        # Get the relevant answers for this survey from the submitted data.
        answers = extract_answers metadata_table, params

        # Return an error if required answers were missing.
        return :answers_missing if @required.count > 0

        # Return true if form processed successfully.
        return :completed
    end

    def extract_answers(table, params)
        # Create an empty hash.
        answers = {}

        # Based on each
        table.where(:current => true).all do |row|
            # Check if the answer_name is part of an array (indicated in the database by the use of square brackets).
            if row[:answer_name].index(/\[(?:.+)\]/) == nil
                value = (params[row[:answer_name]] == nil || params[row[:answer_name]].empty?) ? nil : params[row[:answer_name]]
            else
                # Get the base answer name.
                base = row[:answer_name].gsub(/(\[(?:[^\[]+)\])/, '')

                # Get the names for each dimension of the array (the second dimension may be nil).
                dimensions = row[:answer_name].scan(/(?:\[([^\[\]]+)\])/)
                first_d = (dimensions[0][0] && dimensions[0][0].match(/^\d+$/)) ? dimensions[0][0].to_i : dimensions[0][0]
                second_d = (dimensions[1]) ? dimensions[1][0] : nil
                second_d = (second_d && second_d.match(/^\d+$/)) ? second_d.to_i : second_d

                # Assign the value based on whether the second dimension exists.
                if first_d && second_d
                    value = (params[base] == nil || params[base][first_d] == nil || params[base][first_d][second_d] == nil || params[base][first_d][second_d].empty?) ? nil : params[base][first_d][second_d]
                elsif first_d
                    value = (params[base][first_d] == nil || params[base][first_d].empty?) ? nil : params[base][first_d]
                end
            end

            if value
                answers[row[:answer_name]] = value
            elsif row[:required]
                @required.push row[:answer_name]
            end
        end

        return answers
    end

end