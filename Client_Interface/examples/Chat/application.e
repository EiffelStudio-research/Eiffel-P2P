note
	description : "chat application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		do
			create utils.make
			create login.make (utils)
			create mainmenue.make (utils)
			create chatroom.make (utils)
			start
		end
feature {NONE} --Logic
	start
	do
		from  login.show
		until utils.currentstate = -1
		loop
			if utils.currentstate = 0 then
				print("****You are now logged out ****%N")
				login.show
			elseif utils.currentstate = 1 then
				print("****MAIN MENUE****")
				mainmenue.show
			elseif utils.currentstate = 2 then
				print("****CHATROOM****")
				chatroom.show
			end
		end
	end

feature {NONE} --Fields

	utils:CHAT_UTILS
	login:LOGIN
	mainmenue:MAINMENUE
	chatroom:CHATROOM

end
