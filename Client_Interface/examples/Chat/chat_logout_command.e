note
	description: "Summary description for {CHAT_LOGOUT_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CHAT_LOGOUT_COMMAND

create
	make

feature -- Initialization

	make (a_chat: CHAT_CLIENT)
		do
			chat := a_chat
		end

feature --Screen

	show
		local
			input : STRING
			logout_success: BOOLEAN
		do

			io.put_string ("Enter the name you want to logout: ")

			io.read_line
			input := ""
			input.append (io.last_string)
			chat.playername := input

			logout_success := logout_server (input)
			if logout_success then
				chat.currentState := 3
			else
				print(chat.get_error_message + "%N")
			end

		end

feature --Implementation

	logout_server (a_name:STRING): BOOLEAN
		require
			not_empty: not a_name.is_empty
		do
			Result := chat.logout (a_name)
		end

feature{NONE} -- Implementation

	chat: CHAT_CLIENT

invariant
	chat_not_void: not (chat = void)
end
