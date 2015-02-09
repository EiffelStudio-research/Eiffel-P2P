note
	description : "[
						This is the root class. The server listens in an endless loop for incoming packets. When a packet
						arrives it parses it to a JSON_OBJECT, detects the message type and passes the JSON_OBJECT to 
						the corresponding handler.
				  ]"
	date        : "$Date$"
	revision    : "$Revision$"

class
	P2P_RENDEZVOUS_SERVER

inherit
	SHARED_EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			setup: P2P_SERVER_SETUP
			i,n: INTEGER
			args: ARGUMENTS_32
			s: READABLE_STRING_32
		do
			create setup.make (8888, 1_024)

			from
				args := execution_environment.arguments
				i := 1
				n := args.argument_count
			until
				i > n
			loop
				if args.argument (i).same_string_general ("--port") then
					if i < n then
						s := args.argument (i)
						if s.is_integer then
							setup.set_port (s.to_integer)
						end
						i := i + 1
					end
				elseif args.argument (i).same_string_general ("--packet-maxsize") then
					if i < n then
						s := args.argument (i)
						if s.is_integer then
							setup.set_maximum_packet_size (s.to_integer)
						end
						i := i + 1
					end
				end
				i := i + 1
			end

			create clients.make
			create socket.make_bound (setup.port)
			if socket.is_bound then
				listen (setup)
			else
				print ("Server is not able to bind port " + setup.port.out + " !%N")
			end
		end

feature -- networking

	listen (a_setup: P2P_SERVER_SETUP)
		local
			pac: PACKET
		do
			from
				print ("SERVER listening on port " + socket.port.out + " %N%N")
			until
				False
			loop
				pac := socket.received (a_setup.maximum_packet_size, 0)
				print ("%NReceived packet -> parsing to JSON_OBJECT: ")
				if attached parse_packet (pac) as json_object then
					print ("succeeded %N")
					process (json_object) -- TODO: nicer if processing would be done in a worker_thread
				else
					print ("failed %N")
				end
			end

			print ("SERVER STOPPED %N%N")
		end

feature -- message handling

	parse_packet (packet: PACKET): detachable JSON_OBJECT
	 	local
	 		i: INTEGER
			received_string: STRING
			json_parser:JSON_PARSER
	 	do
			Result := Void
				--Parse packet to string
			if attached packet as pac then
				from
					i := 1
					received_string := ""
				until
					i > pac.count
				loop
					received_string.append_character (pac.element (i-1))
					i := i + 1
				end
				if  pac.count > 0 then
						-- Try to parse the JSON Object
					create json_parser.make_with_string (received_string)
					json_parser.parse_content
					if json_parser.is_valid then
						Result := json_parser.parsed_json_object
					end
				end
			end
		end

 	process (json_object: JSON_OBJECT)
 		local
 			type: INTEGER_64
 		do
 			if attached {JSON_NUMBER} json_object.item ({P2P_PROTOCOL_CONSTANTS}.message_type_key) as type_number then
 				type := type_number.integer_64_item
 			 	print ("Message is of type: " + type.out + " which means ")

 			 	inspect type
 			 	when {P2P_PROTOCOL_CONSTANTS}.register_message then
 			 		print ("register message %N")
					handle_register (json_object)
 			 	when {P2P_PROTOCOL_CONSTANTS}.query_message then
 			 		print ("query message %N")
					handle_query (json_object)
 			 	when {P2P_PROTOCOL_CONSTANTS}.unregister_message then
 			 		print ("unregister message %N")
					handle_unregister (json_object)
				when {P2P_PROTOCOL_CONSTANTS}.registered_users_message then
					print ("registered_users message %N")
					handle_registered_users
 			 	else
 			 		print ("invalid type %N")

 			 	end
 			else
 				print ("Message is invalid (no type) %N")
 			end

 		end

feature {NONE} -- handlers

	handle_register (json_object: JSON_OBJECT)
		local
			client_name: STRING
			address: NETWORK_SOCKET_ADDRESS
			error: INTEGER_64

			json_register_answer: JSON_OBJECT
		do
				-- generate response
			create json_register_answer.make

				-- put the message type
			put_type (json_register_answer, {P2P_PROTOCOL_CONSTANTS}.register_message)

				-- put unknown error, might be replaced
			replace_error (json_register_answer, {P2P_PROTOCOL_CONSTANTS}.unknown_error)

				-- get the name
			if attached {JSON_STRING} json_object.item ({P2P_PROTOCOL_CONSTANTS}.name_key) as name then
				client_name := name.item
				print ("register: " + client_name + " ")
				if attached socket.peer_address as client_address then
						-- we must create a new object to insert into the database
					create address.make_from_address_and_port (client_address.host_address, client_address.port)
					error := clients.register (client_name, address)
					replace_error (json_register_answer, error)
				else
					print ("no valid peer_address")
				end

			else
				print ("invalid name_key")
			end
			print ("%N")

			send_answer (json_register_answer)
		end

	handle_unregister (json_object: JSON_OBJECT)
		local
			client_name: STRING
			error: INTEGER_64

			json_unregister_answer: JSON_OBJECT
		do
				-- generate response
			create json_unregister_answer.make

				-- put the message type
			put_type (json_unregister_answer, {P2P_PROTOCOL_CONSTANTS}.unregister_message)

				-- put unknown error, might be replaced
			replace_error (json_unregister_answer, {P2P_PROTOCOL_CONSTANTS}.unknown_error)

				-- get the name
			if attached {JSON_STRING} json_object.item ({P2P_PROTOCOL_CONSTANTS}.name_key) as name then
				client_name := name.item
				print ("unregister: " + client_name + " ")
				if attached socket.peer_address as client_address then
					error := clients.unregister (client_name, client_address)
					replace_error (json_unregister_answer, error)
				else
					print ("no valid peer_address")
				end

			else
				print ("invalid name_key")
			end
			print ("%N")

			send_answer (json_unregister_answer)
		end

	handle_registered_users
		local
			json_array: JSON_ARRAY
			json_users_answer: JSON_OBJECT
		do
				-- generate response
			create json_users_answer.make

				-- create message type
			put_type (json_users_answer, {P2P_PROTOCOL_CONSTANTS}.registered_users_message)

				-- create json_array
			create json_array.make_empty
			across clients.peers as ic loop
				json_array.extend (create {JSON_STRING}.make_from_string (ic.key))
			end

			json_users_answer.put (json_array, {P2P_PROTOCOL_CONSTANTS}.registered_users_key)
			send_answer (json_users_answer)
		end

	handle_query (json_object: JSON_OBJECT)
		local
			json_query_answer: JSON_OBJECT
		do
				-- generate response
			create json_query_answer.make

				-- put the message type
			put_type (json_query_answer, {P2P_PROTOCOL_CONSTANTS}.query_message)

				-- put unknown error, might be replaced
			replace_error (json_query_answer, {P2P_PROTOCOL_CONSTANTS}.unknown_error)

				-- get the name
			if attached {JSON_STRING} json_object.item ({P2P_PROTOCOL_CONSTANTS}.name_key) as name then
				if clients.is_client_registered (name.item) then
					if attached clients.peer_address (name.item) as peer_address  then
							-- put the error type
						replace_error (json_query_answer, {P2P_PROTOCOL_CONSTANTS}.no_error)

							-- put the ip_address
						put_string (json_query_answer, {P2P_PROTOCOL_CONSTANTS}.ip_key, peer_address.host_address.host_address)

							-- put the port
						put_integer (json_query_answer, {P2P_PROTOCOL_CONSTANTS}.port_key, peer_address.port)
					end
				else
					-- put error
					replace_error (json_query_answer, {P2P_PROTOCOL_CONSTANTS}.client_not_registered)
					print (" query failed, no such registered user " + name.item + "%N")
				end
			end

			send_answer (json_query_answer)
		end

feature {NONE} -- helpers

	new_packet (json_object: JSON_OBJECT): PACKET
		local
			string_rep: STRING
			i: INTEGER
		do
			string_rep := json_object.representation
			create Result.make (string_rep.count)
			from
				i := 1
			until
				i > string_rep.count
			loop
				Result.put_element (string_rep.item (i), i - 1)
				i := i + 1
			end
		end

	send_answer (json_object: JSON_OBJECT)
		do
				-- generate packet and send back to sender
			if attached socket.peer_address as address then
				print ("send answer to: " + address.host_address.host_address + ":" + address.port.out + "%N")
				socket.send_to (new_packet (json_object), address, 0)
			else
					-- probably nothing can be done -> no response
			end
		end

	put_string (json_object: JSON_OBJECT; a_key: STRING; a_value: STRING)
		do
			json_object.put_string (a_value, a_key)
		end

	put_integer (json_object: JSON_OBJECT; a_key: STRING; a_value: INTEGER_64)
		do
			json_object.put_integer (a_value, a_key)
		end

	put_type (json_object: JSON_OBJECT; type: INTEGER_64)
		do
			put_integer (json_object, {P2P_PROTOCOL_CONSTANTS}.message_type_key, type)
		end

	replace_error (json_object: JSON_OBJECT; error: INTEGER_64)
			-- if not present it will be inserted
		do
			json_object.replace_with_integer (error, {P2P_PROTOCOL_CONSTANTS}.error_type_key)
		end

feature {NONE} --data

	socket: NETWORK_DATAGRAM_SOCKET
	clients: CLIENT_DATABASE

end
