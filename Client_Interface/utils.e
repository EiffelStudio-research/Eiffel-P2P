note
	description: "This classs gives the basic values"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	UTILS

<<<<<<< HEAD
=======



>>>>>>> e1127ad43c4153f3445b6ef98755037ed3d50127
feature -- sleep intervals in ns
	send_thread_interval:INTEGER_64 = 2000000000

	receive_thread_interval:INTEGER_64 = 2000000000

	keep_alive_thread_interval: INTEGER_64 = 10000000000

feature --Timeouts in ms
	thread_join_timeout: NATURAL = 10000




feature -- socket constants

	server_ip : STRING_8 =  "188.63.191.24" -- ip of rendevouz server
	server_port : INTEGER_32 = 8888 -- must be the same as rendevouz server

	server_address : NETWORK_SOCKET_ADDRESS
	once
		create Result.make_from_hostname_and_port (server_ip, server_port)
	end

	local_port : INTEGER_32 = 40001

	application_message_string: INTEGER = 5
	application_message_json: INTEGER = 6

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

	-- message types
	register_message: INTEGER = 1

	query_message: INTEGER = 2

	unregister_message: INTEGER = 3

	keep_alive_message: INTEGER = 4




end
