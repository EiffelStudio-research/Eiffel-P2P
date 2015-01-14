note
	description : "[
						This is the root class. The server listens in an endless loop for incoming packets. When a packet
						arrives it parses it to a JSON_OBJECT, detects the message type and passes the JSON_OBJECT to 
						the corresponding handler.
				  ]"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		do
			create socket.make_bound ({UTILS}.local_server_port)
			create clients.make

			listen

		end


feature -- networking
	listen
		local
			pac: PACKET


		do
			from
				print("SERVER STARTED %N%N")
			until
				False
			loop
				pac :=  socket.received ({UTILS}.maximum_packet_size, 0)
				print("%NReceived packet -> parsing to JSON_OBJECT: ")
				if attached parse_packet(pac) as json_object then
					print("succeeded %N")
					process(json_object) -- TODO: nicer if processing would be done in a worker_thread
				else
					print("failed %N")
				end
			end

			print("SERVER STOPED %N%N")
		end




feature -- message handling

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
 			 	when {UTILS}.register_message then
 			 		print("register message %N")
					handle_register(json_object)
 			 	when {UTILS}.query_message then
 			 		print("query message %N")
					handle_query(json_object)
 			 	when {UTILS}.unregister_message then
 			 		print("unregister message %N")
					handle_unregister(json_object)
				when {UTILS}.registered_users_message then
					print("registered_users message %N")
					handle_registered_users
 			 	else
 			 		print("invalid type %N")

 			 	end
 			else
 				print("Message is invalid (no type) %N")
 			end

 		end

feature {NONE} -- handlers

	handle_register(json_object: JSON_OBJECT)
		local
			client_name: STRING
			address: NETWORK_SOCKET_ADDRESS
			error: INTEGER_64

			name_key: JSON_STRING
			name_value: detachable JSON_VALUE
			json_register_answer: JSON_OBJECT
		do

			-- generate response
			create json_register_answer.make

			-- put the message type
			put_type (json_register_answer, {UTILS}.register_message)

			-- put unknown error, might be replaced
			replace_error (json_register_answer, {UTILS}.unknown_error)

			-- get the name
			create name_key.make_from_string ({UTILS}.name__key)
			name_value := json_object.item (name_key)
			if attached {JSON_STRING}  name_value as name then
				client_name := name.item
				print("register: " + client_name + " ")
				if attached socket.peer_address as client_address then
					-- we must create a new object to insert into the database
					create address.make_from_address_and_port (client_address.host_address, client_address.port)
					error := clients.register (client_name, address)
					replace_error (json_register_answer, error)
				else
					print("no valid peer_address")
				end

			else
				print("invalid name_key")
			end
			print("%N")

			send_answer (json_register_answer)
		end

	handle_unregister(json_object: JSON_OBJECT)
		local
			client_name: STRING
			address: NETWORK_SOCKET_ADDRESS
			error: INTEGER_64

			name_key: JSON_STRING
			name_value: detachable JSON_VALUE
			json_unregister_answer: JSON_OBJECT
		do
			-- generate response
			create json_unregister_answer.make

			-- put the message type
			put_type (json_unregister_answer, {UTILS}.unregister_message)

			-- put unknown error, might be replaced
			replace_error (json_unregister_answer, {UTILS}.unknown_error)

			-- get the name
			create name_key.make_from_string ({UTILS}.name__key)
			name_value := json_object.item (name_key)
			if attached {JSON_STRING}  name_value as name then
				client_name := name.item
				print("unregister: " + client_name + " ")
				if attached socket.peer_address as client_address then
					error := clients.unregister (client_name, client_address)
					replace_error (json_unregister_answer, error)
				else
					print("no valid peer_address")
				end

			else
				print("invalid name_key")
			end
			print("%N")

			send_answer (json_unregister_answer)
		end

	handle_registered_users
		local
			key: JSON_STRING
			value: JSON_VALUE

			json_array: JSON_ARRAY
			json_users_answer: JSON_OBJECT

			reg_clients: ARRAY[STRING]
		do
			-- generate response
			create json_users_answer.make

			-- create message type
			put_type (json_users_answer, {UTILS}.registered_users_message)

			-- create json_array
			create key.make_from_string ({UTILS}.registered_users_key)
			create json_array.make_empty

			reg_clients := clients.get_clients

			across reg_clients as client
			loop
				value := create {JSON_STRING}.make_from_string (client.item)
				json_array.extend (value)
			end
			-- array is filled

			json_users_answer.put (json_array, key)

			send_answer (json_users_answer)

		end

	handle_query(json_object: JSON_OBJECT)
		local
			name_key: JSON_STRING
			name_value: detachable JSON_VALUE
			json_query_answer: JSON_OBJECT
		do
			-- generate response
			create json_query_answer.make

			-- put the message type
			put_type (json_query_answer, {UTILS}.query_message)

			-- put unknown error, might be replaced
			replace_error (json_query_answer, {UTILS}.unknown_error)

			-- get the name
			create name_key.make_from_string ({UTILS}.name__key)
			name_value := json_object.item (name_key)
			if attached {JSON_STRING}  name_value as name then
				if clients.is_client_registered (name.item) then
					if attached {NETWORK_SOCKET_ADDRESS} clients.query_address (name.item) as peer_address  then
						-- put the error type
						replace_error (json_query_answer, {UTILS}.no_error)

						-- put the ip_address
						put_string (json_query_answer, {UTILS}.ip_key, peer_address.host_address.host_address)

						-- put the port
						put_integer (json_query_answer, {UTILS}.port_key, peer_address.port)
					end
				else
					-- put error
					replace_error (json_query_answer, {UTILS}.client_not_registered)
					print(" query failed, no such registered user " + name.item + "%N")
				end
			end

			send_answer (json_query_answer)

		end


feature {NONE} -- helpers

	generat_packet(json_object: JSON_OBJECT): PACKET
		local
			string_rep:  STRING
			i: INTEGER
		do
			string_rep := json_object.representation
			create RESULT.make (string_rep.count)
			from i := 1
			until i > string_rep.count
			loop
				RESULT.put_element (string_rep.item (i), i-1)
				i := i+1
			end
		end

	send_answer(json_object: JSON_OBJECT)
		do
			-- generate packet and send back to sender
			if attached socket.peer_address as address then
				print("send answer to: " + address.host_address.host_address + ":" + address.port.out + "%N")
				socket.send_to (generat_packet (json_object), address, 0)
			else
				-- probably nothing can be done -> no response
			end
		end

	put_string(json_object: JSON_OBJECT key: STRING value: STRING)
		local
			j_key: JSON_STRING
			j_value: JSON_STRING
		do
			create j_key.make_from_string (key)
			create j_value.make_from_string (value)
			json_object.put (j_value, j_key)
		end

	put_integer(json_object: JSON_OBJECT key: STRING value: INTEGER_64)
		local
			j_key: JSON_STRING
			j_value: JSON_NUMBER
		do
			create j_key.make_from_string (key)
			create j_value.make_integer (value)
			json_object.put (j_value, j_key)
		end

	put_type(json_object: JSON_OBJECT type: INTEGER_64)
		do
			put_integer(json_object, {UTILS}.message_type_key, type)
		end

	replace_error(json_object: JSON_OBJECT error: INTEGER_64)
	-- if not present it will be inserted
		local
			j_key: JSON_STRING
		do
			create j_key.make_from_string ({UTILS}.error_type_key)
			json_object.replace_with_integer (error, j_key)
		end




feature {NONE} --data

	socket: NETWORK_DATAGRAM_SOCKET
	clients: CLIENT_DATABASE

end
