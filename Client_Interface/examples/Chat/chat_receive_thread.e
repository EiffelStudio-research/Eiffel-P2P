note
	description: "Summary description for {CHAT_RECEIVE_THREAD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CHAT_RECEIVE_THREAD

inherit
	THREAD

create
	make_with_chat

feature -- Initialization

	make_with_chat (a_chat: CHAT_CLIENT)

		do
			make -- create thread
			chat := a_chat
		end

feature --Execute

	execute
		do
			from
			until
				chat.conn_manager.manager_terminated
			loop
				if attached chat.conn_manager.receive_blocking as message then
					io.put_string (message)
					print("%N%N")
				end
			end
			print("chat_receive_thread finished %N")
		end

feature {NONE} -- Implementation

	chat: CHAT_CLIENT

end
