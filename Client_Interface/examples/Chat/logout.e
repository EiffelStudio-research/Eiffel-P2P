note
	description: "Summary description for {LOGOUT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LOGOUT

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
		input : STRING
		logout_success: BOOLEAN
	do

		io.put_string ("Enter the name you want to logout: ")

		io.read_line
		input := ""
		input.append (io.last_string)
		utils.playername := input

		logout_success := logout_server (input)
		if logout_success then
			utils.currentState := 3
		else
			print(utils.get_error_message + "%N")
		end

	end

feature --Implementation
	logout_server(aname:STRING): BOOLEAN
	require
		not_empty: not aname.is_empty
	do
		RESULT := utils.logout(aname)
	end

feature{NONE} --UTILS
	utils:CHAT_UTILS

invariant
	utils_not_void: not (utils = void)
end
