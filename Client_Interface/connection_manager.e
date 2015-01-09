note
	description: "Summary description for {CONNECTION_MANAGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CONNECTION_MANAGER

create
	make

feature -- Extern

	make
		do
			print("Created UTILS %N")


			{utils}.set_send_thread_running (True)
			create socket.make_bound ({utils}.local_port)

			create send_queue.make
			create receive_queue.make

			create udp_sender.make_by_socket (socket, send_queue)
			create udp_receiver.make_by_socket (socket, receive_queue)


			udp_sender.launch
			print("launched sender %N")
--			udp_receiver.launch
--			print("launched receiver %N")
		end

	register(a_name: STRING)
		local
			t_pac: TARGET_PACKET
		do
			create t_pac.make_register_packet (a_name)
			send_queue.extend (t_pac)
		end


--		send(a_object: JSON_OBJECT)
--		do
--			Utils.send_queue.extend (a_object)
--			print("Added JSON Object to Sender Queue: " + a_object.representation + "%N")
--		end

	wait_sender_timeout
		local
			timed_out: BOOLEAN
		do
			timed_out:= udp_sender.join_with_timeout (80000)
		end

		start
		do
			--connector.launch
		end

		close
		local
			test: BOOLEAN
		do

			--Wait 10 Seconds
			--test := connector.join_with_timeout (10000)

		end

feature {NONE} -- intern


feature {NONE} -- Thread QUeues

	send_queue:MUTEX_LINKED_QUEUE
	receive_queue:MUTEX_LINKED_QUEUE


feature {NONE} -- THread
	--connector : CONNECTION_MANAGER_THREAD

	socket: NETWORK_DATAGRAM_SOCKET

	udp_receiver: UDP_RECEIVE_THREAD
	udp_sender: UDP_SEND_THREAD
end
