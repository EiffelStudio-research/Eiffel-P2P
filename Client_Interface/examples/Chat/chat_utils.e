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

	login(chat_name: STRING)
		do
			conn_manager.start
			conn_manager.register (chat_name)
		end

	connect(a_peer_name: STRING): BOOLEAN
		do
			RESULT := conn_manager.connect (a_peer_name)
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
