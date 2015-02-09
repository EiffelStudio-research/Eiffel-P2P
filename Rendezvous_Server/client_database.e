note
	description: "[
					This class provides an interface for the APPLICATION class. It is client of HASH_TABLE[NETWORK_SOCKET_ADDRESS, STRING]
					which is the implementation of the database. The different features are the interface to this
					table where the public IP/Port for each user are stored.
				 ]"
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
			create peers.make (30)
		end

feature -- access

	peer_address (client_name: STRING): detachable NETWORK_SOCKET_ADDRESS
		do
			Result := peers [client_name]
			if	attached Result as address then
				print("queried ip of " + client_name + " is : " + address.host_address.host_address + ":" + address.port.out + "%N")
			end
		end

	is_client_registered (client_name: STRING) : BOOLEAN
		do
			Result := peers.has (client_name)
		end

	count: INTEGER
		do
			Result := peers.count
		end

	peers:  HASH_TABLE [NETWORK_SOCKET_ADDRESS, STRING]
			-- Peers address by client name.

feature -- Change

	register (client_name: STRING; address: NETWORK_SOCKET_ADDRESS): INTEGER_64
		do
			Result := {P2P_PROTOCOL_CONSTANTS}.unknown_error
			if
				peers.has (client_name) and then
				attached peers [client_name] as registered_address
			then
				if address.is_equal (registered_address) then -- check if registered address equals the new one
					print(" failed, client already registered")
					Result := {P2P_PROTOCOL_CONSTANTS}.client_already_registered
				else
					print(" failed, username already used")
					Result := {P2P_PROTOCOL_CONSTANTS}.client_name_already_used
				end
			else
				peers.put (address, client_name)
				print (" " + address.host_address.host_address + ":" + address.port.out + " succeeded")
				Result := {P2P_PROTOCOL_CONSTANTS}.no_error
			end
		end

	unregister (client_name: STRING; address: NETWORK_SOCKET_ADDRESS) : INTEGER_64
		do
			Result := {P2P_PROTOCOL_CONSTANTS}.unknown_error
			if
				peers.has (client_name) and then
				attached peers [client_name] as registered_address
			then
				if address.is_equal (registered_address) then -- check if registered address equals the new one
					print(" success, name and ip match")
					peers.remove (client_name)
					Result := {P2P_PROTOCOL_CONSTANTS}.no_error
				else
					print(" failed, invalid unregister attempt (name and ip did not match)")
					Result := {P2P_PROTOCOL_CONSTANTS}.invalid_unregister_attempt
				end
			else
				print(" failed, no such registered user")
				Result := {P2P_PROTOCOL_CONSTANTS}.client_not_registered
			end
		end

end
