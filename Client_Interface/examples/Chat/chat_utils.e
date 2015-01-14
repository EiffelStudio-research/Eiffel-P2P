note
	description: "Contains all the basic values {UTILS}."
	author: "Simon Peyer"
	date: "$Date$"
	revision: "$Revision$"

class
	CHAT_UTILS
create
	make

feature -- make
	make
	do
		create conn_manager.make
		playerName := ""
	end

feature -- Data
	serverIP:STRING = "188.63.191.24"

	playerName:STRING assign setPlayerName
	currentState:INTEGER assign setCurrentState
	-- 0 = LOGIN SCREEN; 1 = MAIN MENUE; 2 = CHAT ROOM

	peer_name: STRING

feature -- Access
	setCurrentState(aState : INTEGER)
	do
		currentState := aState
	end

	setPlayerName(aName:STRING)
	do
		playerName := aName
	end

	set_peer_name(a_peer_name: STRING)
	do
		peer_name := a_peer_name
	end

feature -- connection

	start
		do
	 		conn_manager.start
		end

	login(chat_name: STRING): BOOLEAN
		do
			RESULT := conn_manager.register (chat_name)
			error_type := conn_manager.register_error_type
		end

	logout(chat_name: STRING): BOOLEAN
		do
			RESULT := conn_manager.unregister (chat_name)
			error_type := conn_manager.unregister_error_type
		end

	connect(a_peer_name: STRING): BOOLEAN
		do
			RESULT := conn_manager.connect (a_peer_name)
			error_type := conn_manager.connect_error_type
		end

	error_type: INTEGER_64

	get_error_message: STRING
		do
			inspect error_type
			when {UTILS}.no_error then
				RESULT := " no error occured"
			when {UTILS}.unknown_error then
				RESULT := " an unknown error occured"
			when {UTILS}.server_down then
				RESULT := " the server on " + {UTILS}.server_ip + ":" + {UTILS}.server_port.out + " is not responding in time. Maybe increase the server_timeout in UTILS"
			when {UTILS}.client_already_registered then
				RESULT := " you are already registered"
			when {UTILS}.client_not_registered then
				RESULT := " the client you wanted to connect to is not registered"
			when {UTILS}.client_name_already_used then
				RESULT := " there is already another client with the same name. Please choose another username"
			when {UTILS}.client_not_responding then
				RESULT := " the client you wanted to connect to is not responding"
			when {UTILS}.invalid_unregister_attempt then
				RESULT := " you are not allowed to logout someone with another ip than yours"
			else
				RESULT :=" an invalid error_type occured"
			end
		end

	exit
	 	do
	 		conn_manager.stop
	 	end

	send(a_message: STRING)
		do
			conn_manager.send (a_message)
		end

feature {CHAT_RECEIVE_THREAD}-- connection manager
	conn_manager: CONNECTION_MANAGER

invariant
	rightState: currentState >= -1 or currentState <= 3

end
