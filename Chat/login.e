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
	make(aUtils: UTILS)

	do
		utils := aUtils
	end

feature --Screen
	show
	local
		input : STRING
	do
		io.put_string ("This is the login page for Server " + utils.serverIP)
		io.put_new_line
		io.put_string ("Enter your Chat name: ")

		io.read_line
		input := ""
		input.append (io.last_string)
		utils.playername := input

		loginserver (input)
		utils.currentState := 1
	end

feature --Implementation
	loginServer(aname:STRING)
	require
		not_empty: not aname.is_empty
	do
		-- TODO acces to
	end

feature{NONE} --UTILS
	utils:UTILS

invariant
	utils_not_void: not (utils = void)
end
