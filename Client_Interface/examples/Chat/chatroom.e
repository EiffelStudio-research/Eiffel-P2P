note
	description: "Active Chat Room"
	author: "Simon Peyer"
	date: "$Date$"
	revision: "$Revision$"

class
	CHATROOM
create
	make

feature --Make clausel
	make(aUtils: CHAT_UTILS)

	do
		utils := aUtils
	end

feature --Screen
	show
	local
		input:STRING
		receiver: CHAT_RECEIVE_THREAD
	do
		showIntro
		if connect then
			from
				create receiver.make_with_utils (utils)
				receiver.launch

				io.put_string ("Enter a Text to chat, if you want exit enter :exit")
				io.put_new_line
				io.put_string ("*********************")
				io.put_new_line
				io.new_line
				io.read_line
				input:=io.last_string
			until
				input.starts_with (":exit")
			loop
				io.new_line
				--input.prepend (utils.playerName + " says: ")
				--io.put_string (input)
				send(input)
				io.new_line
				io.read_line
				input:=io.last_string
			end
		end
		utils.exit
		utils.currentstate := 1
	end

	connect: BOOLEAN
		local
			remote_name: STRING
		do
			io.put_string ("Enter the name of the peer you want to chat with: ")
			io.read_line
			remote_name := io.last_string
			utils.set_peer_name (remote_name)
			io.put_new_line
			RESULT := utils.connect (remote_name)
		end

	showIntro
	do
		io.put_new_line
		io.put_string ("*********************")
		io.put_new_line
		io.put_string ("You are logged in as: " + utils.playerName)
		io.put_new_line

	end

feature --Implementation

	send(aText:STRING)
	do
		utils.send (aText)
	end

feature {NONE} --UTILS
	utils:CHAT_UTILS

invariant
	utils_not_void: not (utils = void)
end
