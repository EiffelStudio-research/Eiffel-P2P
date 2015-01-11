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
				False -- TODO: Find proper termination condition
			loop
				peer_message := utils.conn_manager.receive_blocking
				io.putstring (peer_message)
				io.new_line
			end
			print("Receive_Thread finished %N")
		end



feature {NONE} --UTILS
	utils:CHAT_UTILS
end
