note
	description: "Summary description for {CLIENT_DATABASE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CLIENT_DATABASE

create
	make


feature -- initialization

	make
		do
			create database.make (30)
		end

feature -- access

	register(client_name: STRING address: NETWORK_SOCKET_ADDRESS) : BOOLEAN
		do
			if database.has (client_name) then
				RESULT := False
			else
				database.put (address, client_name)
				RESULT := TRUE
			end
		end

feature {NONE}
	database:  HASH_TABLE[NETWORK_SOCKET_ADDRESS, STRING]



end
