note
	description: "Shows the login screen and logs the User into the system"
	author: "Simon Peyer"
	date: "$Date$"
	revision: "$Revision$"

class
	CHAT_LOGIN_COMMAND

create
	make

feature -- Implementation

	make (a_chat: CHAT_CLIENT)
		do
			chat := a_chat
		end

feature -- Screen

	show
		local
			input : STRING
			login_success: BOOLEAN
		do
			io.put_string ("This is the login page for Server " + chat.serverIP)
			io.put_new_line
			io.put_string ("Enter your Chat name: ")

			io.read_line
			input := ""
			input.append (io.last_string)
			chat.playername := input

			login_success := login_server (input)
			if login_success then
				chat.currentState := 1
			else
				print (chat.get_error_message + "%N")
				if chat.error_type = {P2P_PROTOCOL_CONSTANTS}.client_already_registered then -- we are already registered
					chat.currentstate := 1
				end
			end

		end

feature --Implementation

	login_server (a_name:STRING): BOOLEAN
		require
			a_name_not_empty: not a_name.is_empty
		do
			Result := chat.login (a_name)
		end

feature {NONE} -- Implementation

	chat: CHAT_CLIENT

invariant
	utils_not_void: not (chat = void)
end
