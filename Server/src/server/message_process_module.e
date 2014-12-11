note
	description: "Summary description for {RESPONSE_GENERATE_MODULE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MESSAGE_PROCESS_MODULE
create
	make
feature {ANY}
	make
		do
			create my_record_list.make
		end
	generate_response(handler: PROTOCOL_HANDLER): MY_PACKET
		require
			known_protocol: handler.is_known

		local
			act: ACTION
		do
			act := handler.generate_action
			
			create RESULT.make_empty
			if
				act.has_action
			then
				inspect
					act.action_name
				when 0 then
					RESULT := handler.generate_response (my_record_list.add_record (act.target_record), my_record_list)
				when 1 then
					RESULT := handler.generate_response (my_record_list.edit_record (act.target_record), my_record_list)
				else
					RESULT := handler.generate_response (false, my_record_list)
				end
			else
				RESULT := handler.generate_response (true, my_record_list)
			end
		end

feature {NONE}
	my_record_list: MY_RECORD_LIST

end
