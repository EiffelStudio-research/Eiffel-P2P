note
	description : "ewfp2pserver application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	P2PSERVER

inherit
	ARGUMENTS
	SOCKET_RESOURCES
	STORABLE

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		do
			--| Add your code here
			create packet_processor.make
			create message_processor.make
			print("hello")
			listen(8888, 10)
		end


feature
	listen(port: INTEGER; queue: INTEGER)
		require
			valid_port: valid_port(port)
			valid_queue: valid_queue(queue)
		local
			count: INTEGER
			socket: detachable NETWORK_STREAM_SOCKET
		do
			create socket.make_server_by_port(port)
			socket.listen (queue)
			from
				count := 0
			until
				count = 5
			loop
				print("hahahahaha%N")
				process(socket)
			end
			socket.cleanup

		rescue
			if socket /= Void then
				print("hehehehhe%N")
				socket.cleanup
			end
		end

	process(soc: detachable NETWORK_STREAM_SOCKET)
		require
			soc_not_void: soc /= Void
		local
			current_response: MY_PACKET
			protocol_handler: PROTOCOL_HANDLER
		do
			soc.accept
			if attached soc.accepted as soc2 then
				print("A client connected!%N")
				if attached {MY_PACKET} retrieved (soc2) as packet then
					print("A packet received!%N")
					protocol_handler := packet_processor.process_packet(packet, soc2.peer_address)
					if
						protocol_handler.is_known
					then
						print("This is a known protocol!%N")
						current_response := message_processor.generate_response (protocol_handler)
					else
						print("This is an unknown protocol!%N")
						create current_response.make_empty
					end
					if
						not current_response.is_empty
					then
						current_response.independent_store (soc2)
						print("The packet is replied%N")
					else
						print("The packet is ignored%N")
					end
				end




			end
			print("Client disconnected!%N")
		rescue
			print("unknow exception happens%N")
		end
feature

	packet_processor: PACKET_PROCESS_MODULE
	message_processor: MESSAGE_PROCESS_MODULE
	valid_port(port: INTEGER): BOOLEAN
		do
			RESULT := (port > 1023)
		end

	valid_queue(queue: INTEGER): BOOLEAN
		do
			RESULT := (queue > 0)
		end
end
