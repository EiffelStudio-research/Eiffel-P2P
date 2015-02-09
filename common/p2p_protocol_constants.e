note
	description: "[
			Constants used in the P2P protocol
						
			note: protocol must be the same as for rendezvouz_server
		]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	P2P_PROTOCOL_CONSTANTS

feature -- Protocol: json keys

	name_key: STRING = "name"
	ip_key: STRING = "ip_address"
	port_key: STRING = "port"

	message_type_key: STRING = "type"
	data_key: STRING = "data"

	registered_users_key: STRING = "users"

	error_type_key: STRING = "error"

feature -- Protocol: message types

	register_message: INTEGER = 1

	query_message: INTEGER = 2

	unregister_message: INTEGER = 3

	keep_alive_message: INTEGER = 4

	application_message: INTEGER = 5

	registered_users_message: INTEGER = 6

	hole_punch_message: INTEGER = 7

feature -- Protocol: error types

	unknown_error: INTEGER_64 = -2

	server_down: INTEGER_64 = -1
			-- the server is not responding in time

	no_error: INTEGER_64 = 0
			-- no error occured

	client_already_registered: INTEGER_64 = 1
			-- you are already registered

	client_not_registered: INTEGER_64 = 2
			-- the client you tried to query for is not registered

	client_name_already_used: INTEGER_64 = 3
			-- the client name for registering is already in use

	client_not_responding: INTEGER_64 = 4
			-- the client you tried to connect did not respond. he might not be ready yet. maybe increase connecting_duration

	invalid_unregister_attempt: INTEGER_64 = 5
			-- the client you tried to unregister was not registered by you (name and ip did not match)	

end
