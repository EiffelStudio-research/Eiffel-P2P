
note
	description: "Summary description for {UDP_SEND_THREAD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	UDP_SEND_THREAD

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

feature -- Execute

	execute
		do
			from

			until
				not utils.send_thread_running
			loop
				if Utils.send_queue.something_to_send then

					if  Utils.send_queue.readable then
						send
					end
				else
					current.sleep (utils.send_thread_timeout)
				end


			end
		end

	send
		require
			socket_not_void: socket /= Void

		local
			pac: PACKET
			i: INTEGER
		do
			if attached socket as soc then
				create t.make_now
				if attached {TARGET_PACKET} utils.send_queue.item as target_packet then

					print("Picked up a Packet to send %N")

					create t.make_now
					soc.send_to (target_packet, target_packet.peer_address, 0)

					print("Sent packet "  + t.out + "%N")
				end

			end
		end

feature {NONE} --data
	utils:UTILS

end
