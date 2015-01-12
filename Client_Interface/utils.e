note
	description: "This classs gives the basic values"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	UTILS

feature -- sleep intervals in ns
	send_thread_interval:INTEGER_64 = 2000000000 -- 2s  time send thread sleeps when nothing to send

	keep_alive_thread_interval: INTEGER_64 = 10000000000

	receive_client_interval: INTEGER_64 = 10000000

	query_answer_interval: INTEGER_64 = 4000000000 -- 4s  time client maximal waits for query answer of server

	hole_punch_interval: INTEGER_64 = 3000000000

feature --Timeouts in ms
	thread_join_timeout: NATURAL = 10000

	connecting_duration: INTEGER_32 = 10
	-- time hole punching is active in seconds




feature -- socket constants

	server_ip : STRING_8 =  "188.63.191.24" -- ip of rendezvous server
	server_port : INTEGER_32 = 8888 -- must be the same as rendevouz server

	server_address : NETWORK_SOCKET_ADDRESS
	once
		create Result.make_from_hostname_and_port (server_ip, server_port)
	end

	local_port : INTEGER_32 = 40001



feature -- protocol must be the same as for rendevouz_server

	-- for receive
	maximum_packet_size: INTEGER = 1024

	--for query
	maximum_query_retries: INTEGER = 3

	-- json keys
	name__key: STRING = "name"
	ip_key: STRING = "ip_address"
	port_key: STRING = "port"

	message_type_key: STRING = "type"
	data_type_key: STRING = "data"

	error_type_key: STRING = "error"

	-- message types
	register_message: INTEGER = 1

	query_message: INTEGER = 2

	unregister_message: INTEGER = 3

	keep_alive_message: INTEGER = 4

	application_message_string: INTEGER = 5

	application_message_json: INTEGER = 6

	hole_punch_message: INTEGER = 7

	-- error types
	unknown_error: INTEGER_64 = -2

	server_down: INTEGER_64 = -1
	-- the server is not responding in time

	no_error: INTEGER_64 = 0
	-- no error occured

	client_already_registered: INTEGER_64 = 1
	-- you are already registered

	client_not_registered: INTEGER_64 = 2
	-- the client you tried to query for is not registered

	client_not_responding: INTEGER_64 = 3
	-- the client you tried to connect did not respond. he might not be ready yet. maybe increase connecting_duration




feature -- output
	debugging: BOOLEAN = False
	line_break: STRING = "----------------------------------------------------------------- %N"
end
