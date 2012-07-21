class Tag
	
	def survey_open
		%{<form id="{{id}}" class="survey_form" enctype="multipart/form-data" action="/sent" method="post">}
	end

	def survey_close
		%{</form>}
	end

	def group_open
		%{<div id="{{id}}" class="survey_group">}
	end

	def group_close
		%{</div>}
	end

	def table_open
		%{
			<table id="{{id}}" class="survey_table">
				<thead>
					<tr>
						<th></th>
						{{#answers}}
						<th class="survey_answer">{{answer}}</th>
						{{/answers}}
					</tr>
				</thead>
		}
	end

	def table_row
		%{
			<tr>
				<td class="survey_query">{{query}}</td>
				{{#responses}}
				<td class="survey_answer">{{response}}</td>
				{{/responses}}
			</tr>
		}
	end

	def table_close
		%{</table>}
	end

	def question
		%{
			<div id="{{id}}" class="survey_question">
				{{{heading_tag}}}
				{{{query_tag}}}
				{{{instruction_tag}}}
				{{{widget_tag}}}
			</div>
		}
	end

	def heading
		%{<h3>{{heading}}</h3>}
	end

	def query
		%{<p class="survey_question">{{query}}</p>}
	end

	def instruction
		%{<p class="survey_instruction">{{instruction}}</p>}
	end

	def checkbox
		%{<input name="{{name}}[]" type="checkbox" value="{{value}}" />}
	end

	def file
		%{<input name="{{name}}" type="file" />}
	end

	def radio
		%{<input name="{{name}}" type="radio" value="{{value}}" {{checked}}/>}
	end

	def select
		%{
			<select name="{{name}}[]">
				{{#responses}}
					<option value="{{value}}" {{selected}}>{{label}}</option>
				{{/responses}}
			</select>
		}
	end

	def text_area
		%{<textarea name="{{name}}">{{default}}</textarea>}
	end

	def text
		%{<input name="{{name}}" type="text" value="{{default}}" />}
	end
end