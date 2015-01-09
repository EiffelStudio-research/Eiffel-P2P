note
	description: "This classs gives the basic values"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	UTILS


feature --Timeouts
	send_thread_timeout:INTEGER
		do
			Result := 2000000000
		end
	receive_thread_timeout:INTEGER
		do
			Result := 2000
		end

feature -- Thread Control
	send_thread_running:BOOLEAN
	receive_thread_running:BOOLEAN

	set_send_thread_running(v : BOOLEAN)
	do
		send_thread_running := v
	end

	set_receive_thread_running(v:BOOLEAN)
	do
		receive_thread_running := v
	end

feature -- socket constants

	server_ip : STRING_8 =  "188.63.191.24" -- ip of rendevouz server
	server_port : INTEGER_32 = 8888 -- must be the same as rendevouz server

	server_address : NETWORK_SOCKET_ADDRESS
	once
		create Result.make_from_hostname_and_port (server_ip, server_port)
	end

	local_port : INTEGER_32 = 40001

	application_message: INTEGER = 5

feature -- protocol must be the same as for rendevouz_server

	maximum_packet_size: INTEGER = 1024

	-- json keys
	name__key: STRING = "name"
	ip_key: STRING = "ip_address"
	port_key: STRING = "port"

	message_type_key: STRING = "type"


	-- message types
	register_message: INTEGER = 1

	query_message: INTEGER = 2

	unregister_message: INTEGER = 3

	keep_alive_message: INTEGER = 4



end
