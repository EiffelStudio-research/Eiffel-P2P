
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
				not send_thread_running
			loop
				print("Send_Thread awake: ")
				if Utils.send_queue.something_to_send then
					print("something to send -> send %N")
					if  Utils.send_queue.readable then
						send
					end
				else
					print("nothing to send -> sleep %N")
					current.sleep (utils.send_thread_interval)
				end


			end
			print("Send_Thread finished %N")
		end

	send
		require
			socket_not_void: socket /= Void

		local
			t: TIME
		do
			if attached socket as soc then
				create t.make_now
				if attached {TARGET_PACKET} utils.send_queue.item as target_packet then

					print("Picked up a Packet to send %N")

					create t.make_now
					soc.set_peer_address (target_packet.peer_address)
					soc.send (target_packet, 0)

					print("Sent packet to " + target_packet.peer_address.host_address.host_address + ":" + target_packet.peer_address.port.out + " at "  + t.out + "%N")
				end

			end
		end

feature {CONNECTION_MANAGER} -- Thread Control
	send_thread_running:BOOLEAN

	set_send_thread_running(v : BOOLEAN)
	do
		send_thread_running := v
	end



feature {NONE} --data
	utils:UTILS

end
