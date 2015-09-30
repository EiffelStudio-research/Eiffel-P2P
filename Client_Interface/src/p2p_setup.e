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
	P2P_SETUP

create
	make_default,
	make

feature {NONE} -- Initialization

	make_default
		do
			make ("127.0.0.1", 8888, 40001, 40010)
		end

	make (a_server_ip: READABLE_STRING_8; a_server_port: INTEGER; a_local_port_lower, a_local_port_upper: INTEGER)
		require
			local_port_range_valid: a_local_port_upper >= a_local_port_lower
		do
			server_ip := a_server_ip
			server_port := a_server_port
			local_port_interval := a_local_port_lower |..| a_local_port_upper
		end

feature -- Settings

	server_ip : STRING_8
			-- Remote rendezvouz server IP.

	server_port : INTEGER_32
			-- Remote rendezvouz server port.

	local_port_interval : INTEGER_INTERVAL
			-- Port value range for local connection.

feature -- Sleep intervals in nanoseconds

	send_thread_interval: INTEGER_64 = 2_000_000_000
			-- 2s time send thread sleeps when nothing to send

	keep_alive_thread_interval: INTEGER_64 = 10_000_000_000
			-- 10s time keep_alive_thread sleeps between sending keep_alive messages

	receive_client_interval: INTEGER_64 = 10_000_000
			-- 10ms time receive sleeps when nothing is in receive_queue

	hole_punch_interval: INTEGER_64 = 2_000_000_000
			-- 2s period we sleep between sending hole_punch messages

	server_answer_check_interval: INTEGER_64 = 100_000_000
			-- 100ms period that we check if server responded (register, query, unregister)

feature -- Timeouts

	thread_join_timeout: NATURAL = 10_000
			-- time we let each thread after setting the termination flag until it terminates in milliseconds.

	connecting_timeout: INTEGER_32 = 20
			-- time hole punching is active in seconds (time we let two clients connect).

	server_timeout: INTEGER_32 = 6
			-- time we maximal wait for an answer of the server in seconds.

feature -- Protocol: packet size

	maximum_packet_size: INTEGER = 1024

feature -- output

	debugging: BOOLEAN = False

	line_break: STRING = "----------------------------------------------------------------- %N"

end
