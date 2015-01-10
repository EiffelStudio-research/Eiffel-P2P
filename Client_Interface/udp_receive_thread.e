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


	make_by_socket(ref_socket: detachable NETWORK_DATAGRAM_SOCKET; a_receive_queue: MUTEX_LINKED_QUEUE)

		do
			make
			socket := ref_socket
			receive_queue := a_receive_queue
		end

feature --Execute

	execute
		do
			from

			until
				not receive_thread_running
			loop
				listen
<<<<<<< HEAD
				current.sleep ({utils}.receive_thread_interval)
=======
>>>>>>> e1127ad43c4153f3445b6ef98755037ed3d50127
			end
			print("Receive_Thread finished %N")
		end

	listen
		require
			socket_not_void: socket /= Void

		local
			pac: PACKET
		do
			if attached socket as soc then
				pac :=  soc.received ({UTILS}.maximum_packet_size, 0)
				print("Received Packet ")
				receive_queue.force (pac)

			end
		end

feature {CONNECTION_MANAGER} -- Thread Control
	receive_thread_running:BOOLEAN

	set_receive_thread_running(v:BOOLEAN)
	do
		receive_thread_running := v
	end

<<<<<<< HEAD
=======
feature {NONE} --data
>>>>>>> e1127ad43c4153f3445b6ef98755037ed3d50127

	receive_queue:MUTEX_LINKED_QUEUE
end
