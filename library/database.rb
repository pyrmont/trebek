require 'sequel'

class Database

    def initialize(filename)
        # Set up the datastore.
        @store = Sequel.sqlite filename
    end

    def get_possible_answers(survey_id)
        # Get the metadata table.
        metadata_table = get_table :metadata, survey_id

        # Return all current possible answers.
        return metadata_table.where(:current => true).all
    end

    def save_survey(survey_name, all_answers)
        # Prune answers.
        answers = prune_answers all_answers

        # Create the surveys table.
        create_table :surveys

        # Get the surveys table.
        surveys_table = get_table :surveys

        # Get the survey_id and determine if this is an update to an existing survey.
        if survey_id = surveys_table.where(:name => survey_name).get(:id)
            is_update = true
        else
            # Save this survey into the surveys table.
            survey_id = surveys_table.insert :name => survey_name, :open => false, :created_at => DateTime.now
            is_update = false
        end

        # Convert survey_id into a string for easier manipulation later.
        survey_id = survey_id.to_s

        if is_update
            # Get the metadata table.
            metadata_table = get_table :metadata, survey_id

            # Set all answers to false.
            metadata_table.update(:current => false)

            # For each answer either update the existing record in the metadata table or create a new record.
            answers.each do |answer|
                unless 1 == metadata_table.where(:answer_name => answer.name).update(:survey_id => survey_id, :answer_name => answer.name, :answer_text => answer.text, :question_text => answer.question, :title_text => answer.title, :format => answer.format, :required => answer.required?, :current => true, :updated_at => DateTime.now)
                    metadata_table.insert :survey_id => survey_id, :answer_name => answer.name, :answer_text => answer.text, :question_text => answer.question, :title_text => answer.title, :format => answer.format, :required => answer.required?, :current => true, :created_at => DateTime.now
                end
            end

            # Get the columns for the responses table.
            columns = (get_table :responses, survey_id).columns

            # Get the name of the response table.
            table_name = get_table_name :responses, survey_id

            # For each answer, insert a column in the responses table if it doesn't exist.
            answers.each do |answer|
                unless columns.include? answer.name.to_sym
                    @store.add_column table_name, answer.name, String, :text => true
                end
            end
        else
            # Create the table for the answer metadata.
            create_table :metadata, survey_id

            # Get the metadata table.
            metadata_table = get_table :metadata, survey_id

            # Insert the metadata for each answer into the metadata table.
            answers.each do |answer|
                metadata_table.insert :survey_id => survey_id, :answer_name => answer.name, :answer_text => answer.text, :question_text => answer.question, :title_text => answer.title, :format => answer.format, :required => answer.required, :current => true, :created_at => DateTime.now
            end

            # Create the table for the answer responses.
            create_table :responses, survey_id

            # Get the name of the response table.
            table_name = get_table_name :responses, survey_id

            # Insert a column for each answer.
            answers.each do |answer|
                @store.add_column table_name, answer.name, String, :text => true
            end
        end

        # Return the survey_id variable.
        return survey_id
    end

    def save_response(survey_id, answers)
        # Get the responses table.
        responses_table = get_table :responses, survey_id

        # Set up the remaining elements of the hash.
        answers[:survey_id] = survey_id
        answers[:session] = ''
        answers[:created_at] = DateTime.now

        # Insert a row for this answer.
        responses_table.insert answers
    end

    def survey_exists?(survey_id)
        # Get the survey table.
        surveys_table = get_table :surveys

        # Return whether the survey exists or not.
        result = (surveys_table.where(:id => survey_id).count == 0) ? false : true
        return result
    end

    def survey_open?(survey_id)
        # Get the survey table.
        surveys_table = get_table :surveys

        # Return whether the survey is closed or not.
        return surveys_table.where(:id => survey_id).get(:open)
    end

    private

        def prune_answers(all_answers)
            # Create an empty array.
            pruned_answers = []

            # Create a nil object.
            previous_name = nil

            all_answers.each do |answer|
                # Set the answer text to be the empty string if this is a select or radio.
                answer.text = nil if answer.type == :select || answer.type == :radio

                # Add the answer to the pruned answers.
                pruned_answers.push answer unless answer.name == previous_name

                # Set the previous name to be this element.
                previous_name = answer.name
            end

            # Return the pruned answers.
            pruned_answers
        end

        def create_table(table_type, survey_id = nil)
            # Unless the table_type is :surveys, return nil if survey_id wasn't provided.
            return nil if table_type != :surveys && survey_id == nil

            # Set the name for the table.
            name = (table_type == :surveys) ? table_type : (get_table_name(table_type, survey_id))

            # Return if table exists.
            return nil if @store.table_exists?(name)

            # Create the table based on the type.
            case table_type
            when :surveys
                @store.create_table :surveys do
                    primary_key :id
                    String :name, :text=> true
                    TrueClass :completed
                    TrueClass :open
                    DateTime :created_at
                    DateTime :updated_at
                end
            when :metadata
                @store.create_table name do
                    primary_key :id
                    foreign_key :survey_id, :surveys
                    String :answer_name, :text => true
                    String :answer_text, :text => true
                    String :question_text, :text => true
                    String :title_text, :text => true
                    String :format, :text => true
                    TrueClass :required
                    TrueClass :current
                    DateTime :created_at
                    DateTime :updated_at
                end
            when :responses
                @store.create_table name do
                    primary_key :id
                    foreign_key :survey_id, :surveys
                    String :session, :text => true
                    DateTime :created_at
                    DateTime :updated_at
                end
            end

            # Return true if successful.
            return true
        end

        def get_table_name(table_type, survey_id)
            return ('survey_' + survey_id + '_' + table_type.to_s).to_sym
        end

        def get_table(table_type, survey_id = nil)
            # Unless the table_type is :surveys, return nil if survey_id wasn't provided.
            return nil if table_type != :surveys && survey_id == nil

            # Set the name for the table.
            name = (table_type == :surveys) ? table_type : get_table_name(table_type, survey_id)

            # Retrieve the table.
            table = @store[name]

            # Return the table.
            return table
        end

end