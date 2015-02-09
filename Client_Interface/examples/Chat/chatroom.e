note
	description: "Active Chat Room"
	author: "Simon Peyer"
	date: "$Date$"
	revision: "$Revision$"

class
	CHATROOM

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
			receiver: CHAT_RECEIVE_THREAD
		do
			show_intro
			print_users
			if connect then
				from
					create receiver.make_with_chat (chat)
					receiver.launch

					io.put_string ("Enter a Text to chat, if you want exit enter :exit")
					io.put_new_line
					io.put_string ("*********************")
					io.put_new_line
					io.read_line
					input := io.last_string
				until
					input.starts_with (":exit")
				loop
					input.prepend (chat.playerName + " says: ")
					send(input)
					io.new_line
					io.read_line
					input := io.last_string
				end
			else
				print(chat.get_error_message + "%N")
			end

			chat.currentstate := 1
		end

	print_users
		do
			if chat.get_users then
				print("Registered users: |")
				across chat.users as user
				loop
					print(" " + user.item + " |" )
				end
				print("%N")
			else
				print(chat.get_error_message  + "%N")
			end
		end

	connect: BOOLEAN
		local
			remote_name: STRING
		do
			io.put_string ("Enter the name of the peer you want to chat with: ")
			io.read_line
			remote_name := io.last_string
			chat.set_peer_name (remote_name)
			io.put_new_line
			Result := chat.connect (remote_name)
		end

	show_intro
		do
			io.put_new_line
			io.put_string ("*********************")
			io.put_new_line
			io.put_string ("You are logged in as: " + chat.playerName)
			io.put_new_line

		end

feature --Implementation

	send (a_text: STRING)
		do
			chat.send (a_text)
		end

feature {NONE} -- Implementation

	chat: CHAT_CLIENT

invariant
	chat_not_void: not (chat = void)

end
