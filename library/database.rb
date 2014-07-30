require 'sequel'

class Database

    def initialize(filename)
        # Open the @store.
        @store = Sequel.sqlite filename

        # Create the survey table.
        unless @store.table_exists?(:surveys)
            @store.create_table :surveys do
                primary_key :id
                String :name, :text=> true
                TrueClass :completed
                TrueClass :open
                DateTime :created_at
                DateTime :updated_at
            end
        end
    end

    def save_survey(survey_name, answers)
        # Insert the details about this survey into the table.
        surveys_table = @store[:surveys]
        if survey_id = surveys_table.where(:name => survey_name).get(:id)
            is_update = true
        else
            survey_id = surveys_table.insert :name => survey_name, :open => false, :created_at => DateTime.now # Note: This is adapter dependent.
            is_update = false
        end
        survey_id = survey_id.to_s

        # Set the name of the tables.
        metadata_name = ('survey_' + survey_id + '_metadata').to_sym
        responses_name = ('survey_' + survey_id + '_responses').to_sym

        if is_update
            # Insert updated metadata for each answer into the table.
            metadata_table = @store[metadata_name]
            metadata_table.update(:current => false)
            answers.each do |answer|
                unless 1 == metadata_table.where(:answer_name => answer.answer_id).update(:survey_id => survey_id, :answer_name => answer.answer_id, :answer_text => answer.answer_text, :question_text => answer.question_text, :title_text => answer.title_text, :format => answer.format, :required => answer.required?, :current => true, :updated_at => DateTime.now)
                    metadata_table.insert :survey_id => survey_id, :answer_name => answer.answer_id, :answer_text => answer.answer_text, :question_text => answer.question_text, :title_text => answer.title_text, :format => answer.format, :required => answer.required?, :current => true, :created_at => DateTime.now
                end
            end

            # Update columns in the responses table.
            columns = @store[responses_name].columns
            answers.each do |answer|
                unless columns.include? answer.answer_id.to_sym
                    @store.add_column responses_name.to_sym, answer.answer_id, String, :text => true
                end
            end

        else
            # Create the table for the answer metadata.
            @store.create_table metadata_name do
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

            # Insert the metadata for each answer into the table.
            metadata_table = @store[metadata_name]
            answers.each do |answer|
                metadata_table.insert :survey_id => survey_id, :answer_name => answer.answer_id, :answer_text => answer.answer_text, :question_text => answer.question_text, :title_text => answer.title_text, :format => answer.format, :required => answer.required?, :current => true, :created_at => DateTime.now
            end

            # Create the table for the answer responses.
            @store.create_table responses_name do
                primary_key :id
                foreign_key :survey_id, :surveys
                String :session, :text => true
                DateTime :created_at
                DateTime :updated_at
                answers.each do |answer|
                    String answer.answer_id, :text => true
                end
            end
        end

        # Return the survey_id variable.
        return survey_id
    end

end