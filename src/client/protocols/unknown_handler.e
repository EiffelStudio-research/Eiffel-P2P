note
	description: "Summary description for {UNKNOWN_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	UNKNOWN_HANDLER

inherit
	PROTOCOL_HANDLER

feature
	generate_feedback: FEEDBACK
		local
			status: INTEGER
			comment: STRING
			data: ARRAY[NATURAL_8]
		do
			status := 2
			comment := "Received packet uses an unknown protocol!"
			create data.make_empty
			create RESULT.make (status, comment, data)
		end
	is_known: BOOLEAN
		do
			RESULT := false
		end
	validate_message: BOOLEAN
		do
			RESULT := false
		end
end
