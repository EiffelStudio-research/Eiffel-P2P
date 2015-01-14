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
			create logout.make (utils)
			create mainmenue.make (utils)
			create chatroom.make (utils)
			start
		end
feature {NONE} --Logic
	start
	do
		utils.start
		from
			utils.currentstate := 3
		until utils.currentstate = -1
		loop
			if utils.currentstate = 0 then
				print("**** LOGOUT ****%N")
				logout.show
			elseif utils.currentstate = 1 then
				print("****MAIN MENUE****")
				mainmenue.show
			elseif utils.currentstate = 2 then
				print("****CHATROOM****")
				chatroom.show
			elseif utils.currentstate = 3 then
				print("**** LOGIN ****%N")
				login.show
			end
		end
		utils.exit
	end

feature {NONE} --Fields

	utils:CHAT_UTILS
	login:LOGIN
	logout: LOGOUT
	mainmenue:MAINMENUE
	chatroom:CHATROOM

end
