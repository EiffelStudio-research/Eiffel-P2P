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
	make(aUtils: UTILS)

	do
		utils := aUtils
	end

feature --Screen
	show
	local
		input:STRING
	do
		showIntro
		from
			io.new_line
			io.read_line
			input:=io.last_string
		until
			input.starts_with (":exit")
		loop
			io.new_line
			input.prepend (utils.playerName + " says: ")
			io.put_string (input)
			send(input)
			io.new_line
			io.read_line
			input:=io.last_string
		end
		utils.currentstate := 1
	end

	showIntro

	do
		io.put_new_line
		io.put_string ("*********************")
		io.put_new_line
		io.put_string ("You are logged in as: " + utils.playerName)
		io.put_new_line
		io.put_string ("Enter a Text to chat, if you want exit enter :exit")
		io.put_new_line
		io.put_string ("*********************")
		io.put_new_line
	end

feature --Implementation

	send(aText:STRING)
	do
		-- Send the text to the Client
	end

feature {NONE} --UTILS
	utils:UTILS

invariant
	utils_not_void: not (utils = void)
end
