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
			reset_error
		end

feature -- access

	peer_address (client_name: STRING): detachable NETWORK_SOCKET_ADDRESS
		do
			Result := peers [client_name]
		end

	is_client_registered (client_name: STRING) : BOOLEAN
		do
			Result := peers.has (client_name)
		end

	count: INTEGER
		do
			Result := peers.count
		end

	peers: HASH_TABLE [NETWORK_SOCKET_ADDRESS, STRING]
			-- Peers address by client name.

feature -- Error handling

	reset_error
			-- Reset error info.
		do
			last_error_message := Void
			last_error_code := {P2P_PROTOCOL_CONSTANTS}.no_error
		end

	has_error: BOOLEAN
			-- Has error info.
			-- i.e: previous operation reported an error,
			-- For detail, check `last_error_code' and `last_error_message'.
		do
			Result := last_error_code /= {P2P_PROTOCOL_CONSTANTS}.no_error
		end

	report_error (a_code: like last_error_code; m: detachable READABLE_STRING_8)
			-- Report error with `a_code' and an optional message `m'.
		require
			a_code_valid: a_code /= {P2P_PROTOCOL_CONSTANTS}.no_error
		do
			last_error_message := m
			last_error_code := a_code
		ensure
			has_error: has_error
		end

	last_error_message: detachable READABLE_STRING_8
			-- Last error message if any.

	last_error_code: INTEGER_64
			-- Last error code, otherwise default `{P2P_PROTOCOL_CONSTANTS}.no_error'.

feature -- Change

	register (client_name: STRING; address: NETWORK_SOCKET_ADDRESS)
		do
			reset_error
			if
				peers.has (client_name) and then
				attached peers [client_name] as registered_address
			then
				if address.is_equal (registered_address) then -- check if registered address equals the new one
					report_error ({P2P_PROTOCOL_CONSTANTS}.client_already_registered, "failed, client already registered")
				else
					report_error ({P2P_PROTOCOL_CONSTANTS}.client_name_already_used, "failed, username already used")
				end
			else
				peers.put (address, client_name)
			end
		end

	unregister (client_name: STRING; address: NETWORK_SOCKET_ADDRESS)
		do
			reset_error
			if
				peers.has (client_name) and then
				attached peers [client_name] as registered_address
			then
				if address.is_equal (registered_address) then
						-- check if registered address equals the new one
					peers.remove (client_name)
				else
					report_error ({P2P_PROTOCOL_CONSTANTS}.invalid_unregister_attempt, "failed, invalid unregister attempt (name and ip did not match)")
				end
			else
				report_error ({P2P_PROTOCOL_CONSTANTS}.client_not_registered, "failed, no such registered user")
			end
		end

end
