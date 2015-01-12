note
	description: "Gives option for the user"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MAINMENUE
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
	do
		printMenu
		from
			io.read_line
			input := io.last_string
		until
			input /= void and then (input.is_equal("J") or input.is_equal ("L") or input.is_equal ("E"))
		loop
			printMenu
			io.read_line
			input := io.last_string
		end

		if input.is_equal("J") then
			utils.currentState := 2
		elseif input.is_equal("L") then
			utils.currentState := 0
		elseif input.is_equal("E") then
			utils.currentState := -1
		end

	end

	printMenu
	do
		io.put_new_line
		io.put_string ("*********************")
		io.put_new_line
		io.put_string ("You are logged in as: " + utils.playerName)
		io.put_new_line
		io.put_string ("Choose an Option: ")
		io.put_new_line
		io.put_string ("J oin a Conversation")
		io.put_new_line
		io.put_string ("L ogout")
		io.put_new_line
		io.put_string ("E xit")
		io.put_new_line
		io.put_string ("*********************")
		io.put_new_line
	end

feature --Implementation


feature{NONE} --UTILS
	utils:CHAT_UTILS

invariant
	utils_not_void: utils /= void
end
