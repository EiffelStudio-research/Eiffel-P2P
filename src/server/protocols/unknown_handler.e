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
	generate_response(action_done: BOOLEAN record_list: MY_RECORD_LIST): MY_PACKET
		do
			create RESULT.make_empty
		end
	generate_action: ACTION
		do
			create RESULT.make_no_action
			action_notified := true
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
