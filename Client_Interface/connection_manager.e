note
	description: "Summary description for {CONNECTION_MANAGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CONNECTION_MANAGER
inherit
	EXECUTION_ENVIRONMENT
create
	make

feature -- Extern

	make
		do
			create socket.make_bound ({UTILS}.local_port)
			create send_queue.make
			create receive_queue.make
			create users_online.make_empty

			manager_terminated := True
		end

feature -- Actions

	register(a_name: STRING): BOOLEAN
		local
			t_pac: TARGET_PACKET
			time: TIME
		do
			set_register_success(False, {UTILS}.server_down) -- set per default to server_down, as it will be set in handle_register_answer if we receive something
			create t_pac.make_register_packet (a_name)
			send_queue.extend (t_pac)

			print("%NREGISTERING ACTIVE: %N")
			from
				create time.make_now
				time := time.plus (create {TIME_DURATION}.make_by_seconds ({UTILS}.server_timeout))
			until
				time.is_less_equal (create {TIME}.make_now) or register_success
			loop
				sleep ({UTILS}.server_answer_check_interval)
			end

			if register_success then
				print("REGISTERING SUCEEDED %N")
			else
				print("REGISTERING FAILED -> ")
			end

			RESULT := register_success
		end

	unregister(a_name: STRING): BOOLEAN
		local
			t_pac: TARGET_PACKET
			time: TIME
		do
			set_unregister_success(False, {UTILS}.server_down) -- set per default to server_down, as it will be set in handle_register_answer if we receive something
			create t_pac.make_unregister_packet (a_name)
			send_queue.extend (t_pac)

			print("%NUNREGISTERING ACTIVE: %N")
			from
				create time.make_now
				time := time.plus (create {TIME_DURATION}.make_by_seconds ({UTILS}.server_timeout))
			until
				time.is_less_equal (create {TIME}.make_now) or unregister_success
			loop
				sleep ({UTILS}.server_answer_check_interval)
			end

			if unregister_success then
				print("UNREGISTERING SUCEEDED %N")
			else
				print("UNREGISTERING FAILED -> ")
			end

			RESULT := unregister_success
		end



	connect(a_peer_name: STRING): BOOLEAN
		local
			success: BOOLEAN
		do
			print("%NCONNECTING ACTIVE: %N")
			success := query(a_peer_name)
			if success then
				print(" queried address is: " + peer_address.host_address.host_address + ":" + peer_address.port.out + "%N")

				success := udp_hole_punch

				if success then
					print("%NCONNECTION ESTABLISHED %N%N")
					create keep_alive_sender.make_by_socket (socket, peer_address, send_queue)
					keep_alive_sender.set_keep_alive_thread_running (True)
					keep_alive_sender.launch
					print("launched keep_alive_sender %N")
				end

			end

			if not success then
				print("%NCONNECTION COULD NOT BE ESTABLISHED %N%N")
			end

			set_connect_success

			RESULT := connect_success
		end


	send(a_string: STRING)
		local
			send_packet : TARGET_PACKET
		do
			create send_packet.make_application_packet (peer_address,a_string)
			send_queue.extend (send_packet)
		end

	receive:STRING
	--standart return value
	do
		result:=receive_blocking
	end

	receive_non_blocking:STRING
		local

		do
			result := Void
			if receive_queue.something_in then
				result := receive_queue.item
			end
		end

	receive_blocking:STRING
		local
		do
			from

			until
				receive_queue.something_in or manager_terminated
			loop
				sleep ({UTILS}.receive_client_interval)
			end
			result := receive_non_blocking
		end

	get_registered_users: BOOLEAN
		local
			t_pac: TARGET_PACKET
			time: TIME
		do
			set_registered_users_success(False, {UTILS}.server_down) -- set per default to server_down, as it will be set in handle_register_answer if we receive something
			create t_pac.make_registered_users_packet
			send_queue.extend (t_pac)

			print("%NQUERYING REGISTERED USERS ACTIVE: %N")
			from
				create time.make_now
				time := time.plus (create {TIME_DURATION}.make_by_seconds ({UTILS}.server_timeout))
			until
				time.is_less_equal (create {TIME}.make_now) or register_success
			loop
				sleep ({UTILS}.server_answer_check_interval)
			end

			if registered_users_success then
				print("QUERYING REGISTERED USERS SUCEEDED %N")
			else
				print("QUERYING REGISTERED USERS FAILED -> ")
			end

			RESULT := registered_users_success
		end

	registered_users: ARRAY[STRING]
		do
			create RESULT.make_from_array (users_online)
		end


feature -- Thread control

	start
		require
			manager_is_not_running: manager_terminated
		do
			create udp_sender.make_by_socket (socket, send_queue)
			create udp_receiver.make_by_socket (socket, current)

			print("%NSTART connection manager %N")
			udp_sender.set_send_thread_running (True)
			udp_sender.launch
			print("launched sender %N")
			udp_receiver.set_receive_thread_running (True)
			udp_receiver.launch
			print("launched receiver %N")
			manager_terminated := False
		end

	stop
		local
			not_sender_timed_out, not_receiver_timed_out, not_keep_alive_timed_out: BOOLEAN
			local_address: NETWORK_SOCKET_ADDRESS
			terminate_packet: PACKET
		do
			print("%NSTOP connection manager %N")
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
				print("stop successfull %N")
			else
				print("stop not successfull %N")
			end

			manager_terminated := True
		end

		manager_terminated: BOOLEAN

feature {TEST} -- intern

	query(peer_name: STRING): BOOLEAN
	-- ask server to hand out the public ip of peer_name, if succeeded it is stored in peer_address: if fails due to server down it
	-- can be repeated without any state changes on client and server side -> query is idempotent
		local
			query_packet: TARGET_PACKET
			end_time: TIME
		do
			print("%NQUERYING ACTIVE: %N")
			set_query_success(False, {UTILS}.server_down) -- set per default to server_down, as it will be set in handle_query if we receive something
			create query_packet.make_query_packet (peer_name)
			send_queue.extend (query_packet) -- send the query

			from
				create end_time.make_now
				end_time := end_time.plus (create {TIME_DURATION}.make_by_seconds ({UTILS}.server_timeout))
			until
				end_time.is_less_equal (create {TIME}.make_now) or query_success
			loop
				sleep({UTILS}.server_answer_check_interval)
			end

			if query_success then
				print("QUERYING SUCEEDED -> ")
			else
				print("QUERYING FAILED -> ")
			end
			RESULT:= query_success
		end



	udp_hole_punch: BOOLEAN
		require
			peer_address_set: peer_address /= Void
		local
			hole_punch_pac: TARGET_PACKET
			end_time: TIME
		do
			create hole_punch_pac.make_hole_punch_packet (peer_address)
			print("%NHOLE PUNCHING ACTIVE: %N")
			from
				set_hole_punch_success(False, {UTILS}.client_not_responding)
				create end_time.make_now
				end_time := end_time.plus (create {TIME_DURATION}.make_by_seconds ({UTILS}.connecting_timeout))
			until
				end_time.is_less_equal (create {TIME}.make_now)
			loop
				send_queue.extend (hole_punch_pac)
				sleep({UTILS}.hole_punch_interval)
			end

			if hole_punch_success then
				print("HOLE PUNCHING SUCCEEDED %N")
			else
				print("HOLE PUNCHING FAILED %N")
			end

			RESULT := hole_punch_success

		end

feature {UDP_RECEIVE_THREAD} -- packet / message parsing exlusively called in UDP_RECEIVE_THREAD

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
 			data: detachable JSON_VALUE
 			data_key: JSON_STRING

 			type: INTEGER_64

 			i:INTEGER
 		do
 			create key.make_from_string ({UTILS}.message_type_key)
			create data_key.make_from_string ({UTILS}.data_key)
 			value := json_object.item (key)
 			if attached {JSON_NUMBER} value as type_number then
 				type := type_number.integer_64_item
 			 	output("message is of type: " + type.out + " which means ")

 			 	inspect type
 			 	when {UTILS}.register_message then
					output("register message  %N")
					handle_register_answer(json_object)
 			 	when {UTILS}.query_message then
 			 		output("query answer message %N")
					handle_query_answer(json_object)
				when {UTILS}.unregister_message then
					output("unregister message %N")
					handle_unregister_answer (json_object)
				when {UTILS}.keep_alive_message then
					output("keep alive message, ignore this %N")
				when {UTILS}.application_message then
					output("application message string %N")
					data := json_object.item (data_key)
					receive_queue.force (data.representation.substring (2,data.representation.count - 1))
				when {UTILS}.registered_users_message then
					output("registered_users_message")
					handle_registered_users_answer(json_object)
				when {UTILS}.hole_punch_message then
					output("hole punch message %N")
					set_hole_punch_success (True, {UTILS}.no_error)
 			 	else
 			 		output("invalid type %N")

 			 	end
 			else
 				output("Message is invalid (no type) %N")
 			end

 		end
feature {NONE} -- Client list
	users_online: ARRAY[STRING]


feature {NONE} --  handlers
	handle_registered_users_answer(json_object: JSON_OBJECT)
		local
			array_key: JSON_STRING

			error: BOOLEAN
			index: INTEGER
			size: INTEGER
		do
			set_registered_users_success (False, {UTILS}.unknown_error) -- we received a register_users answer and set per default success to unknown
			create users_online.make_empty

			error := False

			create array_key.make_from_string ({UTILS}.registered_users_key)
			if attached {JSON_ARRAY} json_object.item (array_key) as json_array then
				from
					index := 1
					size := json_array.count
				until
					index = size or error
				loop
					if attached {JSON_STRING} json_array.i_th (index) as json_user then
						users_online.force (json_user.item, index)
					else
						error := True
					end

				end
			else
				error := True
			end

			if not error then
				set_registered_users_success (True, {UTILS}.no_error)
			end
		end

	handle_register_answer(json_object: JSON_OBJECT)
		local
			error_type_key: JSON_STRING
			error_type: INTEGER_64

		do
			set_register_success (False, {UTILS}.unknown_error)  -- we received a register answer and set per default success to unknown
			-- check if there is an error
			create error_type_key.make_from_string ({UTILS}.error_type_key)
			if attached {JSON_NUMBER} json_object.item (error_type_key) as error_type_json then
				error_type := error_type_json.integer_64_item
				inspect error_type
				when {UTILS}.no_error then -- no error
					set_register_success (True, error_type)

				when {UTILS}.client_name_already_used then
					set_register_success (False, error_type)

				when {UTILS}.client_already_registered then
					set_register_success (False, error_type)
				else
					set_register_success (False, {UTILS}.unknown_error)
				end
			end
		end

	handle_unregister_answer(json_object: JSON_OBJECT)
		local
			error_type_key: JSON_STRING
			error_type: INTEGER_64

		do
			set_unregister_success (False, {UTILS}.unknown_error)  -- we received a unregister answer and set per default success to unknown
			-- check if there is an error
			create error_type_key.make_from_string ({UTILS}.error_type_key)
			if attached {JSON_NUMBER} json_object.item (error_type_key) as error_type_json then
				error_type := error_type_json.integer_64_item
				inspect error_type
				when {UTILS}.no_error then -- no error
					set_unregister_success (True, error_type)
				when {UTILS}.client_not_registered then
					set_unregister_success (False, error_type)
				when {UTILS}.invalid_unregister_attempt then
					set_unregister_success (False, error_type)
				else
					set_unregister_success (False, {UTILS}.unknown_error)
				end
			end
		end

	handle_query_answer(json_object: JSON_OBJECT)
		local
			peer_ip_address: STRING
			port_string: STRING
			peer_port: INTEGER

			error_type_key: JSON_STRING
			error_type: INTEGER_64
		do
			set_query_success (False, {UTILS}.unknown_error) -- we received a query answer and set per default success to unknown
			-- check if there is an error
			create error_type_key.make_from_string ({UTILS}.error_type_key)
			if attached {JSON_NUMBER} json_object.item (error_type_key) as error_type_json then
				error_type := error_type_json.integer_64_item
				inspect error_type
				when {UTILS}.no_error then -- no error
					-- try to get peer_ip
					if attached {JSON_STRING} json_object.item ({UTILS}.ip_key) as peer_ip then
						peer_ip_address:= peer_ip.item
						-- try to get peer_port
						if attached {JSON_NUMBER} json_object.item ({UTILS}.port_key) as port then
							port_string:= port.item -- TODO: kind of ugly, is there a way to cast INTEGER_64 to INTEGER_32 ?
							peer_port:= port_string.to_integer_32
							create peer_address.make_from_hostname_and_port (peer_ip_address, peer_port)
							set_query_success(True, error_type)
						end
					end
				when {UTILS}.client_not_registered then
					set_query_success (False, error_type)
				else
					set_query_success (False, {UTILS}.unknown_error)
				end
			end
		end




feature -- public flags and error types
	register_success: BOOLEAN
	unregister_success: BOOLEAN
	connect_success: BOOLEAN
	registered_users_success: BOOLEAN

	register_error_type: INTEGER_64
	unregister_error_type: INTEGER_64
	connect_error_type: INTEGER_64
	registered_users_error_type: INTEGER_64


feature {TEST} -- private flags and error types
	query_success: BOOLEAN
	hole_punch_success: BOOLEAN

	query_error_type: INTEGER_64
	hole_punch_error_type: INTEGER_64

feature {NONE}	-- setters for flags
	set_register_success(received: BOOLEAN error: INTEGER_64)
		do
			register_success := received
			register_error_type := error
		end

	set_unregister_success(received: BOOLEAN error: INTEGER_64)
		do
			unregister_success := received
			unregister_error_type := error
		end

	set_registered_users_success(received: BOOLEAN error: INTEGER_64)
		do
			registered_users_success := received
			registered_users_error_type := error
		end

	set_query_success(received: BOOLEAN error: INTEGER_64)
		do
			query_success := received
			query_error_type := error
		end

	set_hole_punch_success(received: BOOLEAN error: INTEGER_64)
		do
			hole_punch_success := received
			hole_punch_error_type := error
		end

	set_connect_success
	-- depends on query_success and hole_punch_success
		do
			if query_success and hole_punch_success then
				connect_success := True
				connect_error_type := {UTILS}.no_error
			elseif not query_success then
				connect_success := query_success
				connect_error_type := query_error_type
			elseif not hole_punch_success then
				connect_success := hole_punch_success
				connect_error_type := hole_punch_error_type
			end
		end

feature {NONE} -- queues

	send_queue:MUTEX_LINKED_QUEUE [PACKET]
	receive_queue:MUTEX_LINKED_QUEUE [STRING]



feature {TEST} -- THread

	peer_address: NETWORK_SOCKET_ADDRESS

	socket: NETWORK_DATAGRAM_SOCKET

	udp_receiver: UDP_RECEIVE_THREAD
	udp_sender: UDP_SEND_THREAD

	keep_alive_sender: KEEP_ALIVE_THREAD


feature --output

	output(a_output: STRING)
		do
			if {UTILS}.debugging then
				print(a_output)
			end
		end
end
