note
	description: "[
					A Thread that listens on the socket for incoming packets. After having received a packet it uses the CONNECTION_MANAGER's parse_packet and
					process. Therefore it is client of CONNECTION_MANAGER.
				 ]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	UDP_RECEIVE_THREAD

inherit
	THREAD

create
	make_by_socket

feature

	socket: detachable NETWORK_DATAGRAM_SOCKET


	make_by_socket(ref_socket: detachable NETWORK_DATAGRAM_SOCKET; a_connection_manager: CONNECTION_MANAGER)

		do
			make
			socket := ref_socket
			connection_manager := a_connection_manager
		end

feature --Execute

	execute
		do
			from

			until
				not receive_thread_running
			loop
				listen
			end
			print("Receive_Thread finished %N")
		end

	listen
		require
			socket_not_void: socket /= Void
		local
			pac: PACKET
			receive_json : detachable JSON_OBJECT
		do
			if attached socket as soc then
				pac :=  soc.received ({P2P_SETUP}.maximum_packet_size, 0)
				output ({P2P_SETUP}.line_break)
				output ("Received Packet ")
				receive_json := connection_manager.parse_packet (pac)
				if attached receive_json as json then
					connection_manager.process (json)
				end
			end
		end

feature {CONNECTION_MANAGER} -- Thread Control

	receive_thread_running: BOOLEAN

	set_receive_thread_running (v:BOOLEAN)
		do
			receive_thread_running := v
		end

feature {NONE} --data

	connection_manager: CONNECTION_MANAGER

feature --output

	output(a_output: STRING)
		do
			if {P2P_SETUP}.debugging then
				print(a_output)
			end
		end

end
