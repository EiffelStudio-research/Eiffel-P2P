note
	description: "Summary description for {FEEDBACK}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FEEDBACK
create
	make
feature
	make(status: INTEGER comment: STRING data: ARRAY[NATURAL_8])
		do
			my_status := status
			my_comment := comment
			my_data := data
		end

	get_status: INTEGER
		do
			RESULT := my_status
		end

	get_comment: STRING
		do
			RESULT := my_comment
		end

	get_data: ARRAY[NATURAL_8]
		do
			RESULT := my_data
		end
feature {NONE}
	my_status: INTEGER
	my_comment: STRING
	my_data: ARRAY[NATURAL_8]
end
