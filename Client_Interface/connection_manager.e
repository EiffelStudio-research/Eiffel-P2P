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
			create utils.make
			print("Created UTILS %N")



			utils.set_send_thread_running (True)
			create socket.make_bound (utils.local_port)

			create udp_sender.make_by_socket (socket, utils)
			create udp_receiver.make_by_socket (socket, utils)


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
			utils.send_queue.extend (t_pac)
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

		end

		close
		local

		do

			--Wait 10 Seconds


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
 			 	print("Message is of type: " + type.out + " which means")

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
				utils.send_queue.extend (query_packet) --TODO: update to local queue

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




feature --data

	peer_address: NETWORK_SOCKET_ADDRESS
	utils:UTILS

feature {NONE} -- THread

	socket: NETWORK_DATAGRAM_SOCKET

	udp_receiver: UDP_RECEIVE_THREAD
	udp_sender: UDP_SEND_THREAD
end
