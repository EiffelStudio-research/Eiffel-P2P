note
	description: "Summary description for {PROTOCOL_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PROTOCOL_HANDLER
feature
	generate_response(action_done: BOOLEAN record_list: MY_RECORD_LIST): MY_PACKET
		require
			action_notified: action_notified
		deferred
		end
	is_known: BOOLEAN
		deferred
		end
	validate_message: BOOLEAN
		deferred
		end
	generate_action: ACTION
		require
			action_not_notified: not action_notified
		deferred
		ensure
			action_notified: action_notified
		end
	action_notified: BOOLEAN




end
