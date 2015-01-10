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
<<<<<<< HEAD
			create socket.make_bound (utils.local_port)
=======

			create socket.make_bound ({utils}.local_port)

>>>>>>> e1127ad43c4153f3445b6ef98755037ed3d50127
			create send_queue.make
			create receive_queue.make
			create udp_sender.make_by_socket (socket, send_queue)
			create udp_receiver.make_by_socket (socket, receive_queue)

		end

feature -- Actions

	register(a_name: STRING)
		local
			t_pac: TARGET_PACKET
		do
			create t_pac.make_register_packet (a_name)
			send_queue.extend (t_pac)
		end

	connect(a_peer_name: STRING)
		local
			success: BOOLEAN
		do
			success := query(a_peer_name)
			if success then
				print("queried address is: " + peer_address.host_address.host_address + ":" + peer_address.port.out + "%N")

				--udp_hole_punch

				create keep_alive_sender.make_by_socket (socket, peer_address, send_queue)
				keep_alive_sender.set_keep_alive_thread_running (True)
				keep_alive_sender.launch
				print("launched keep_alive_sender %N")
			end


		end

	send_json(a_json :JSON_OBJECT)
		local
			send_packet:TARGET_PACKET
		do
			create send_packet.make_application_packet_json (peer_address, a_json)
			send_queue.extend (send_packet)
		end
	send_string(a_string: STRING)
		local
			send_packet : TARGET_PACKET
		do
			create send_packet.make_application_packet_string (peer_address,a_string)
			send_queue.extend (send_packet)
		end



feature -- Thread control



	start
		do
			udp_sender.set_send_thread_running (True)
			udp_sender.launch
			print("launched sender %N")
			udp_receiver.set_receive_thread_running (True)
			udp_receiver.launch
			print("launched receiver %N")
<<<<<<< HEAD
=======

>>>>>>> e1127ad43c4153f3445b6ef98755037ed3d50127
		end

	stop
		local
			not_sender_timed_out, not_receiver_timed_out, not_keep_alive_timed_out: BOOLEAN
			local_address: NETWORK_SOCKET_ADDRESS
			terminate_packet: PACKET
		do
			-- set per default to true
			not_sender_timed_out := True
			not_receiver_timed_out := True
			not_keep_alive_timed_out := True

			-- stop keep_alive
			if attached keep_alive_sender as keep_alive and then not keep_alive.terminated then
				keep_alive.set_keep_alive_thread_running (False)
				not_keep_alive_timed_out :=	keep_alive.join_with_timeout ({UTILS}.thread_join_timeout)
			end

			-- stop sender
			if not udp_sender.terminated then
				udp_sender.set_send_thread_running (False)
				not_sender_timed_out := udp_sender.join_with_timeout ({UTILS}.thread_join_timeout)
			end

			-- stop receiver
			if not udp_receiver.terminated then
				udp_receiver.set_receive_thread_running (False)
				-- create and send a packet to the socket so the receive_thread awakes from the blocking receive and
				-- sees the receive_thread_running flag set to false
				create local_address.make_localhost ({UTILS}.local_port)
				create terminate_packet.make (0)
				socket.send_to (terminate_packet, local_address, 0)
				not_receiver_timed_out := udp_receiver.join_with_timeout ({UTILS}.thread_join_timeout)
			end

			if not_keep_alive_timed_out and not_receiver_timed_out and not_sender_timed_out then -- otherwise one thread is still running (but should not) and if we close the socket we get a runtime error
				socket.cleanup
			end

		end
feature {NONE} -- packet / message parsing TODO: call these two functions in receive, like in rendevouz_server listen

	parse_packet(packet: PACKET): detachable JSON_OBJECT
	 	local
	 		i: INTEGER
			received_string: STRING
			json_parser:JSON_PARSER
			json_object:detachable JSON_OBJECT
	 	do
			RESULT:= Void
			--Parse packet to string
			if attached packet as pac then
				from  i := 1;received_string := ""
				until i > pac.count
				loop
					received_string.append_character (pac.element(i-1))
					i := i + 1
				end
				if  pac.count > 0 then
					-- Try to parse the JSON Object
					create json_parser.make_with_string(received_string)
					json_parser.parse_content

					if json_parser.is_parsed then
						json_object := json_parser.parsed_json_object
						RESULT:= json_object
					end
				end
			end
		end

 	process(json_object: JSON_OBJECT)
 		local
 			key: JSON_STRING
 			value: detachable JSON_VALUE
 			type: INTEGER_64
 		do
 			create key.make_from_string ({UTILS}.message_type_key)

 			value := json_object.item (key)
 			if attached {JSON_NUMBER} value as type_number then
 				type := type_number.integer_64_item
 			 	print("Message is of type: " + type.out + " which means ")

 			 	inspect type

 			 	when 2 then
 			 		print("query answer message %N")
					handle_query_answer(json_object)
 			 	else
 			 		print("invalid type %N")

 			 	end
 			else
 				print("Message is invalid (no type) %N")
 			end

 		end


feature {NONE} -- intern

<<<<<<< HEAD

=======
>>>>>>> e1127ad43c4153f3445b6ef98755037ed3d50127
	query_success: BOOLEAN

	set_query_success(received: BOOLEAN)
		do
			query_success := received
		end


	query(peer_name: STRING): BOOLEAN  -- ask server to hand out the public ip of peer_name, if succeeded it is stored in peer_address
		local
			query_packet: TARGET_PACKET
			answer_pac: PACKET

			i: INTEGER
		do
			set_query_success(False)
			create query_packet.make_query_packet (peer_name)

			from
				i:= 1
			until
				i = {UTILS}.maximum_query_retries or query_success
			loop
<<<<<<< HEAD
				send_queue.extend (query_packet) --TODO: update to local queue
=======
				send_queue.extend (query_packet)
>>>>>>> e1127ad43c4153f3445b6ef98755037ed3d50127

				answer_pac:= socket.received ({UTILS}.maximum_packet_size, 0)	-- TODO: use our received with timeout

				-- from rendevouz_server listen TODO: can be removed when later using our received
				print("Received packet -> parsing to JSON_OBJECT: ")
				if attached parse_packet(answer_pac) as json_object then
					print("succeeded %N")
					process(json_object) -- TODO: nicer if processing would be done in a worker_thread
				else
					print("failed %N")
				end

			end
			RESULT:= query_success
		end

	-- TODO: to be used  in receive like in rendevouz server
	handle_query_answer(json_object: JSON_OBJECT)
		local
			peer_ip_address: STRING
			port_string: STRING
			peer_port: INTEGER
		do
			set_query_success(False)
			-- try to get peer_ip
			if attached {JSON_STRING} json_object.item ({UTILS}.ip_key) as peer_ip then
				peer_ip_address:= peer_ip.item
				-- try to get peer_port
				if attached {JSON_NUMBER} json_object.item ({UTILS}.port_key) as port then
					port_string:= port.item -- TODO: kind of ugly, is there a way to cast INTEGER_64 to INTEGER_32 ?
					peer_port:= port_string.to_integer_32
					create peer_address.make_from_hostname_and_port (peer_ip_address, peer_port)
					set_query_success(True)
				end
			end

		end

<<<<<<< HEAD
	send_queue:MUTEX_LINKED_QUEUE
	receive_queue:MUTEX_LINKED_QUEUE
	peer_address: NETWORK_SOCKET_ADDRESS
	utils:UTILS

feature {UDP_SEND_THREAD} -- THread
=======
--	udp_hole_punch()
--		local
--			addr: detachable NETWORK_SOCKET_ADDRESS
--			timed_out: BOOLEAN
--		do

--			create addr.make_from_hostname_and_port (a_peer_ip_address, a_peer_port)

--			print("creating out socket!%N")
--			create out_soc.make_bound (a_my_local_port)
--			out_soc.set_peer_address (addr)
--			out_soc.set_reuse_address

--			utils.set_send_thread_running(true)
--			utils.set_receive_thread_running (true)

--			create sender.make_by_socket (out_soc,utils)


--			create receiver.make_by_socket (out_soc,utils)


--			print("launching receiver!%N")
--			receiver.launch

--			print("launching sender!%N")
--			sender.launch


--			--sender.exit

--			sender.join
--			receiver.join

--			if attached in_soc as soc then
--				soc.cleanup
--			end
--			if attached out_soc as soc then
--				soc.cleanup
--			end

--		rescue
--			if attached in_soc as soc then
--				soc.cleanup
--			end
--			if attached out_soc as soc then
--				soc.cleanup
--			end
--		end





	send_queue:MUTEX_LINKED_QUEUE
	receive_queue:MUTEX_LINKED_QUEUE



feature {NONE} -- THread

	peer_address: NETWORK_SOCKET_ADDRESS
>>>>>>> e1127ad43c4153f3445b6ef98755037ed3d50127

	socket: NETWORK_DATAGRAM_SOCKET

	udp_receiver: UDP_RECEIVE_THREAD
	udp_sender: UDP_SEND_THREAD

	keep_alive_sender: KEEP_ALIVE_THREAD
end
