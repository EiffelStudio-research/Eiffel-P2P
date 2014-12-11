note
	description: "Summary description for {RESPONSE_AND_ACTION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ACTION
create
	make, make_no_action

feature
	make(action: INTEGER record: MY_RECORD)
		do
			action_name := action
			target_record := record
			has_action := true

		end
	make_no_action
		do
			action_name := -1
			create target_record.make_invalid
			has_action := false
		end
	action_name: INTEGER
	target_record: MY_RECORD
	has_action: BOOLEAN
end
