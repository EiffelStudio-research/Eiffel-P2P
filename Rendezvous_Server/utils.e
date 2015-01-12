

note
	description: "Summary description for {UTILS}."
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

	keep_alive_message: INTEGER = 4

	registered_users_message: INTEGER = 6

	-- error types
	no_error: INTEGER = 1

	client_already_registered: INTEGER = 1

	client_not_registered: INTEGER = 2

end
