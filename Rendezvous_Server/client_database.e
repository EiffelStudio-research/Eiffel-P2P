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

	register(client_name: STRING address: NETWORK_SOCKET_ADDRESS) : INTEGER_64
		do
			Result := {UTILS}.unknown_error
			if database.has (client_name) and then attached database.at (client_name) as registered_address then

				if address.is_equal (registered_address) then -- check if registered address equals the new one
					print(" failed, client already registered")
					RESULT := {UTILS}.client_already_registered
				else
					print(" failed, username already used")
					RESULT := {UTILS}.client_name_already_used
				end
			else
				database.put (address, client_name)
				print(" " + address.host_address.host_address + ":" + address.port.out + " succeeded")
				RESULT := {UTILS}.no_error
			end
		end

	unregister(client_name: STRING address: NETWORK_SOCKET_ADDRESS) : INTEGER_64
		do
			Result := {UTILS}.unknown_error
			if database.has (client_name) and then attached database.at (client_name) as registered_address then
				if address.is_equal (registered_address) then -- check if registered address equals the new one
					print(" success, name and ip match")
					database.remove (client_name)
					RESULT := {UTILS}.no_error
				else
					print(" failed, invalid unregister attempt (name and ip did not match)")
					RESULT := {UTILS}.invalid_unregister_attempt
				end
			else
				print(" failed, no such registered user")
				RESULT := {UTILS}.client_not_registered
			end
		end

	query_address(client_name: STRING) : detachable NETWORK_SOCKET_ADDRESS
		do
			RESULT := database.at (client_name)
			if	attached Result as address then
				print("queried ip of " + client_name + " is : " + address.host_address.host_address + ":" + address.port.out + "%N")
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
