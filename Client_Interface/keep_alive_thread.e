note
	description: "Summary description for {KEEP_ALIVE_THREAD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	KEEP_ALIVE_THREAD

inherit
	THREAD


create
	make_by_socket

feature

	socket: detachable NETWORK_DATAGRAM_SOCKET


	make_by_socket(ref_socket: detachable NETWORK_DATAGRAM_SOCKET a_peer_address: NETWORK_SOCKET_ADDRESS a_send_queue:MUTEX_LINKED_QUEUE)
		do
			make
			send_queue:=a_send_queue
			socket := ref_socket
			peer_address := a_peer_address
		end

feature -- Execute

	execute
		local
			keep_alive_packet: TARGET_PACKET
		do
			from
				create keep_alive_packet.make_keep_alive_packet (peer_address)
				set_keep_alive_thread_running(False)
			until
				not keep_alive_thread_running
			loop
				send_queue.extend (keep_alive_packet)
				Current.sleep ({UTILS}.keep_alive_thread_interval)
			end
			print("Keep alive thread finished %N")
		end


feature {NONE}
	peer_address: NETWORK_SOCKET_ADDRESS

	send_queue: MUTEX_LINKED_QUEUE

feature {CONNECTION_MANAGER} -- Thread Control
	keep_alive_thread_running:BOOLEAN


	set_keep_alive_thread_running(v:BOOLEAN)
	do
		keep_alive_thread_running := v
	end

end
