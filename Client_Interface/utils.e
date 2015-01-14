note
	description: "[
						This static class provides the constant that are necessary for the p2p protocol to run. Therefore a lot must be 
						equal to the UTILS class of the Rendezvous_Server. For example the error_type constants. Additionally there are constants
						like server_ip or server_port that must be adjusted according to the server. Also the different timeouts and intervals might be 
						changed according to the given network architecture. When setting debugging to true, the outputs from UDP_SEND_THREAD and 
						UDP_RECEIVE_THREAD are displayed

				]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	UTILS

feature -- sleep intervals in ns
	send_thread_interval:INTEGER_64 = 2000000000
	-- 2s  time send thread sleeps when nothing to send

	keep_alive_thread_interval: INTEGER_64 = 10000000000
	-- 10s time keep_alive_thread sleeps between sending keep_alive messages

	receive_client_interval: INTEGER_64 = 10000000
	-- 10ms  time receive sleeps when nothing is in receive_queue

	hole_punch_interval: INTEGER_64 = 2000000000
	-- 2s period we sleep between sending hole_punch messages

	server_answer_check_interval: INTEGER_64 = 100000000
	-- 100ms  period that we check if server responded (register, query, unregister)

feature --Timeouts
	thread_join_timeout: NATURAL = 10000
	-- time we let each thread after setting the termination flag until it terminates in ms

	connecting_timeout: INTEGER_32 = 20
	-- time hole punching is active in seconds (time we let two clients connect)

	server_timeout: INTEGER_32 = 6
	-- time we maximal wait for a  answer of the sewrver in seconds



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

	-- json keys
	name__key: STRING = "name"
	ip_key: STRING = "ip_address"
	port_key: STRING = "port"

	message_type_key: STRING = "type"
	data_key: STRING = "data"

	registered_users_key: STRING = "users"

	error_type_key: STRING = "error"

	-- message types
	register_message: INTEGER = 1

	query_message: INTEGER = 2

	unregister_message: INTEGER = 3

	keep_alive_message: INTEGER = 4

	application_message: INTEGER = 5

	registered_users_message: INTEGER = 6

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

	client_name_already_used: INTEGER_64 = 3
	-- the client name for registering is already in use

	client_not_responding: INTEGER_64 = 4
	-- the client you tried to connect did not respond. he might not be ready yet. maybe increase connecting_duration

	invalid_unregister_attempt: INTEGER_64 = 5
	-- the client you tried to unregister was not registered by you (name and ip did not match)




feature -- output
	debugging: BOOLEAN = False
	line_break: STRING = "----------------------------------------------------------------- %N"
end
