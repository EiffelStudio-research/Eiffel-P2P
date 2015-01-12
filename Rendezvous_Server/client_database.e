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
			if database.has (client_name) then -- TODO maybe we can nevertheless insert a new client
				RESULT := False
			else
				database.put (address, client_name)
				RESULT := TRUE
			end
		end

	query_address(client_name: STRING) : detachable NETWORK_SOCKET_ADDRESS
		do
			RESULT := database.at (client_name)
			if
				attached Result as address
			then
			print("queried ip: " + address.host_address.host_address + ":" + address.port.out + "%N")
			end

		end

	is_client_registered(client_name: STRING) : BOOLEAN
		do
			RESULT := database.has (client_name)
		end

	count: INTEGER
		do
			RESULT := database.count
		end

	get_clients: ARRAY[STRING]
		local
			clients: ARRAY[STRING]
		do
			create clients.make_from_array (database.current_keys)
			RESULT := clients
		end

feature {NONE}
	database:  HASH_TABLE[NETWORK_SOCKET_ADDRESS, STRING]

end
