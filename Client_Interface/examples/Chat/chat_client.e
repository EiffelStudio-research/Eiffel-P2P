note
	description: "Contains all the basic values {UTILS}."
	author: "Simon Peyer"
	date: "$Date$"
	revision: "$Revision$"

class
	CHAT_CLIENT

create
	make

feature -- make

	make (a_p2p_setup: P2P_SETUP)
		do
			p2p_setup := a_p2p_setup
			create conn_manager.make (p2p_setup)
			playerName := ""
		end

	p2p_setup: P2P_SETUP
			-- Setup related to P2P connection.

feature -- Data

	serverIP: STRING
		once
			Result := p2p_setup.server_ip
		end

	playerName: STRING assign setPlayerName

	currentState: INTEGER assign setCurrentState
			-- 0 = LOGIN SCREEN; 1 = MAIN MENUE; 2 = CHAT ROOM

	peer_name: detachable STRING

feature -- Access

	setcurrentstate (a_state: INTEGER)
		do
			currentState := a_state
		end

	setPlayerName (a_name: STRING)
		do
			playerName := a_name
		end

	set_peer_name (a_peer_name: detachable STRING)
		do
			peer_name := a_peer_name
		end

feature -- connection

	start
		do
	 		conn_manager.start
		end

	login (chat_name: STRING): BOOLEAN
		do
			Result := conn_manager.register (chat_name)
			error_type := conn_manager.register_error_type
		end

	logout (chat_name: STRING): BOOLEAN
		do
			Result := conn_manager.unregister (chat_name)
			error_type := conn_manager.unregister_error_type
		end

	connect (a_peer_name: STRING): BOOLEAN
		do
			Result := conn_manager.connect (a_peer_name)
			error_type := conn_manager.connect_error_type
		end

	error_type: INTEGER_64

	get_error_message: STRING
		do
			inspect error_type
			when {P2P_PROTOCOL_CONSTANTS}.no_error then
				Result := " no error occured"
			when {P2P_PROTOCOL_CONSTANTS}.unknown_error then
				Result := " an unknown error occured"
			when {P2P_PROTOCOL_CONSTANTS}.server_down then
				Result := " the server on " + p2p_setup.server_ip + ":" + p2p_setup.server_port.out + " is not responding in time. Maybe increase the server_timeout in UTILS"
			when {P2P_PROTOCOL_CONSTANTS}.client_already_registered then
				Result := " you are already registered"
			when {P2P_PROTOCOL_CONSTANTS}.client_not_registered then
				Result := " the client you chose to connect to is not registered"
			when {P2P_PROTOCOL_CONSTANTS}.client_name_already_used then
				Result := " there is already another client with the same name. Please choose another username"
			when {P2P_PROTOCOL_CONSTANTS}.client_not_responding then
				Result := " the client you wanted to connect to is not responding"
			when {P2P_PROTOCOL_CONSTANTS}.invalid_unregister_attempt then
				Result := " you are not allowed to logout someone with another ip than yours"
			else
				Result := " an invalid error_type occured"
			end
		end

	get_users: BOOLEAN
		do
			Result := conn_manager.get_registered_users
			error_type := conn_manager.registered_users_error_type
		end

	users: ARRAY [STRING]
		do
			Result := conn_manager.registered_users
		end

	exit
		local
			test: BOOLEAN
	 	do
	 		test := logout (playername)
	 		conn_manager.stop
	 	end

	send (a_message: STRING)
		do
			conn_manager.send (a_message)
		end

feature {CHAT_RECEIVE_THREAD} -- connection manager

	conn_manager: CONNECTION_MANAGER

invariant
	rightState: currentState >= -1 or currentState <= 3

end
