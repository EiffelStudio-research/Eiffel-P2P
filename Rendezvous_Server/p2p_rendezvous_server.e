note
	description : "[
						This is the root class. The server listens in an endless loop for incoming packets. When a packet
						arrives it parses it to a JSON_OBJECT, detects the message type and passes the JSON_OBJECT to 
						the corresponding handler.
				  ]"
	date        : "$Date$"
	revision    : "$Revision$"

class
	P2P_RENDEZVOUS_SERVER

inherit
	SHARED_EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			setup: P2P_SERVER_SETUP
			i,n: INTEGER
			args: ARGUMENTS_32
			s: READABLE_STRING_32
			socket: NETWORK_DATAGRAM_SOCKET
		do
			create logger

				-- Default value: port=8888 maxsize=1024
			create setup.make (8888, 1_024)

				-- Parameters passed by arguments:
			from
				args := execution_environment.arguments
				i := 1
				n := args.argument_count
			until
				i > n
			loop
				if args.argument (i).same_string_general ("--port") then
					if i < n then
						s := args.argument (i)
						if s.is_integer then
							setup.set_port (s.to_integer)
						end
						i := i + 1
					end
				elseif args.argument (i).same_string_general ("--packet-maxsize") then
					if i < n then
						s := args.argument (i)
						if s.is_integer then
							setup.set_maximum_packet_size (s.to_integer)
						end
						i := i + 1
					end
				end
				i := i + 1
			end

				-- Launch server
			create clients.make
			create socket.make_bound (setup.port)
			if socket.is_bound then
				listen (socket, setup)
			else
				logger.put_error ("Server is not able to bind port " + setup.port.out + " !")
			end
		end

feature -- Logging

	logger: P2P_RENDEZVOUS_LOGGER

feature -- networking

	listen (a_socket: NETWORK_DATAGRAM_SOCKET; a_setup: P2P_SERVER_SETUP)
		local
			pac: PACKET
			hdl: P2P_RENDEZVOUS_HANDLER
		do
			from
				logger.put_information ("SERVER listening on port " + a_socket.port.out + " %N")
			until
				False or a_socket.expired_socket
			loop
				pac := a_socket.received (a_setup.maximum_packet_size, 0)
				if attached parse_packet (pac) as json_object then
					if attached a_socket.peer_address as client_address then
						logger.put_debug ("Received packet -> parsing to JSON_OBJECT: success")
						create hdl.make (clients, client_address, logger, agent send_packet (?, ?, a_socket))
						hdl.execute (json_object)
							-- TODO: nicer if processing would be done in a worker_thread
							-- FIXME: use SCOOP
					else
						logger.put_debug ("No valid peer_address!")
					end
				else
					logger.put_debug ("Received packet -> parsing to JSON_OBJECT: failure.")
				end
			end

			logger.put_information ("SERVER STOPPED %N")
		end

feature -- Packet handling

	send_packet (a_packet: PACKET; a_peer: NETWORK_SOCKET_ADDRESS; a_socket: NETWORK_DATAGRAM_SOCKET)
		do
			logger.put_debug ("send answer to: " + a_peer.host_address.host_address + ":" + a_peer.port.out)
			a_socket.send_to (a_packet, a_peer, 0)
		end

	parse_packet (a_packet: PACKET): detachable JSON_OBJECT
	 	local
	 		i,n: INTEGER
			l_received_string: STRING
			json_parser:JSON_PARSER
	 	do
				-- Parse packet to string
			from
				i := 1
				n := a_packet.count
				l_received_string := ""
			until
				i > n
			loop
				l_received_string.append_character (a_packet.element (i - 1))
				i := i + 1
			end
			if not l_received_string.is_empty then
					-- Try to parse the JSON Object
				create json_parser.make_with_string (l_received_string)
				json_parser.parse_content
				if json_parser.is_valid then
					Result := json_parser.parsed_json_object
				end
			end
		end

feature {NONE} -- Implementation

	clients: CLIENT_DATABASE

end
