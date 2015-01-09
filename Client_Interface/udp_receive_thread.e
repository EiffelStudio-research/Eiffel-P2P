note
	description: "Summary description for {UDP_RECEIVE_THREAD}."
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


	make_by_socket(ref_socket: detachable NETWORK_DATAGRAM_SOCKET a_utils:UTILS)

		do
			make
			socket := ref_socket
			utils:=a_utils
		end

feature --Execute

	execute
		do
			from
			until not utils.receive_thread_running
			loop
				listen
				current.sleep (utils.receive_thread_timeout)
			end

		end

	listen
		require
			socket_not_void: socket /= Void

		local
			pac: PACKET
		do
			if attached socket as soc then
				soc.set_timeout (10)
				pac :=  soc.received ({UTILS}.maximum_packet_size, 0)
				print("Received Packet ")
				utils.receive_queue.force (pac)

			end
		end
feature {NONE} --data
	utils:UTILS

end
