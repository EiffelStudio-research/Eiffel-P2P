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
		playerName := ""
	end

feature -- Data
	serverIP:STRING = "0.0.0.0"

	playerName:STRING assign setPlayerName
	currentState:INTEGER assign setCurrentState
	-- 0 = LOGIN SCREEN; 1 = MAIN MENUE; 2 = CHAT ROOM

feature -- Access
	setCurrentState(aState : INTEGER)
	do
		currentState := aState
	end

	setPlayerName(aName:STRING)
	do
		playerName := aName
	end

invariant
	rightState: currentState >= -1 or currentState <= 3

end
