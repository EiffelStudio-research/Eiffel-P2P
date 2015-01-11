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
			output: STRING
		do
			from
				create output.make_empty
			until
				False -- TODO: Find proper termination condition
			loop
				peer_message := utils.conn_manager.receive_blocking
				output.append (peer_message)
				io.putstring (output)
				io.new_line
			end
			print("Receive_Thread finished %N")
		end



feature {NONE} --UTILS
	utils:CHAT_UTILS
end
