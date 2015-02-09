note
	description: "Gives option for the user"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CHAT_MAIN_MENU

create
	make

feature -- Initialization

	make (a_chat: CHAT_CLIENT)
		do
			chat := a_chat
		end

feature -- Screen

	show
		local
			input: STRING
		do
			print_menu
			from
				io.read_line
				input := io.last_string
				input.left_adjust
				input.right_adjust
			until
				input.is_case_insensitive_equal_general ("J")
				or input.is_case_insensitive_equal_general  ("L")
				or input.is_case_insensitive_equal_general  ("E")
			loop
				print_menu
				io.read_line
				input := io.last_string
				input.left_adjust
				input.right_adjust
			end

			if input.is_case_insensitive_equal_general ("J") then
				chat.currentState := 2
			elseif input.is_case_insensitive_equal_general ("L") then
				chat.currentState := 0
			elseif input.is_case_insensitive_equal_general ("E") then
				chat.currentState := -1
			end

		end

	print_menu
		do
			io.put_new_line
			io.put_string ("*********************")
			io.put_new_line
			io.put_string ("You are logged in as: " + chat.playerName)
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

feature {NONE} -- Implementation

	chat: CHAT_CLIENT

invariant
	chat_attached: chat /= void
end
