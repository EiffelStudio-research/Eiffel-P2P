

note
	description: "[
						This static class provides the constant that are necessary for the p2p protocol to run. Therefore a lot must be 
						equal to the UTILS class of the Client_Interface. For example the error_type constants.
				 ]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	UTILS

create
	make

feature
	make
	do end

feature -- socket constants

	local_server_port : INTEGER = 8888

feature -- protocol must be the same as for the client_interface

	maximum_packet_size: INTEGER = 1024

	-- json keys
	name__key: STRING = "name"
	ip_key: STRING = "ip_address"
	port_key: STRING = "port"

	message_type_key: STRING = "type"

	registered_users_key: STRING = "users"

	error_type_key: STRING = "error"


	-- message types
	register_message: INTEGER = 1

	query_message: INTEGER = 2

	unregister_message: INTEGER = 3

	registered_users_message: INTEGER = 6


	-- error types
	unknown_error: INTEGER_64 = -2

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
