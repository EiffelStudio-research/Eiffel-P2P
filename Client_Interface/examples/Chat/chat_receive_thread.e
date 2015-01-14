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
	make_with_utils

feature --Make clausel
	make_with_utils(aUtils: CHAT_UTILS)

	do
		make -- create thread
		utils := aUtils
	end

feature --Execute

	execute
		local
			peer_message: STRING
		do
			from

			until
				utils.conn_manager.manager_terminated
			loop
				peer_message := utils.conn_manager.receive_blocking
				if attached peer_message as message then
					io.putstring (peer_message)
					print("%N%N")
				end
			end
			print("chat_receive_thread finished %N")
		end



feature {NONE} --UTILS
	utils:CHAT_UTILS
end
