
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


	make_by_socket(ref_socket: detachable NETWORK_DATAGRAM_SOCKET; a_send_queue : MUTEX_LINKED_QUEUE[PACKET])

		do
			make
			socket := ref_socket
			send_queue := a_send_queue
		end

feature -- Execute

	execute
		do
			from

			until
				not send_thread_running
			loop
				output({UTILS}.line_break)
				output("Send_Thread awake: ")
				if send_queue.something_in then
					output("something to send ->  %N")
					if  send_queue.readable then
						send
					end
				else
					output("nothing to send -> sleep %N")
					current.sleep ({UTILS}.send_thread_interval)
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
				if attached {TARGET_PACKET} send_queue.item as target_packet then
					create t.make_now
					--soc.set_peer_address (target_packet.peer_address) -- TODO: change to send_to
					soc.send_to(target_packet, target_packet.peer_address, 0)

					output("sent packet to " + target_packet.peer_address.host_address.host_address + ":" + target_packet.peer_address.port.out + " at "  + t.out + "%N")
				else
					output("packet is void %N")
				end

			end
		end
feature {NONE} -- Thread QUeues

	send_queue:MUTEX_LINKED_QUEUE[PACKET]

feature {CONNECTION_MANAGER} -- Thread Control
	send_thread_running:BOOLEAN

	set_send_thread_running(v : BOOLEAN)
	do
		send_thread_running := v
	end

feature --output

	output(a_output: STRING)
		do
			if {UTILS}.debugging then
				print(a_output)
			end
		end

end
