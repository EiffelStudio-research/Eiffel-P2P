note
	description: "Shows the login screen and logs the User into the system"
	author: "Simon Peyer"
	date: "$Date$"
	revision: "$Revision$"

class
	LOGIN
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
		login_success: BOOLEAN
	do
		io.put_string ("This is the login page for Server " + utils.serverIP)
		io.put_new_line
		io.put_string ("Enter your Chat name: ")

		io.read_line
		input := ""
		input.append (io.last_string)
		utils.playername := input

		login_success := loginserver (input)
		if login_success then
			utils.currentState := 1
		else
			print(utils.get_error_message + "%N")
			if utils.error_type = {UTILS}.client_already_registered then -- we are already registered
				utils.currentstate := 1
			end
		end

	end

feature --Implementation
	loginServer(aname:STRING): BOOLEAN
	require
		not_empty: not aname.is_empty
	do
		RESULT := utils.login(aname)
	end

feature{NONE} --UTILS
	utils:CHAT_UTILS

invariant
	utils_not_void: not (utils = void)
end
