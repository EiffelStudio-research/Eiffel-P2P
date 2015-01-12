note
	description : "rendezvous_server application root class"
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
			create utils.make
			create socket.make_bound (utils.local_server_port)
			create clients.make

			listen

		end


feature -- networking
	listen
		local
			pac: PACKET


		do
			from
			until
				False
			loop
				pac :=  socket.received ({UTILS}.maximum_packet_size, 0)
				print("Received packet -> parsing to JSON_OBJECT: ")
				if attached parse_packet(pac) as json_object then
					print("succeeded %N")
					process(json_object) -- TODO: nicer if processing would be done in a worker_thread
				else
					print("failed %N")
				end

			end
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

feature {NONE} --helpers

	handle_register(json_object: JSON_OBJECT)
		local
			client_name: STRING
			address: NETWORK_SOCKET_ADDRESS
			success: BOOLEAN

			key: JSON_STRING
			value: detachable JSON_VALUE
		do
			-- get the name
			create key.make_from_string (utils.name__key)
			value := json_object.item (key)
			if attached {JSON_STRING} value as name then
				client_name := name.item
				print("register: " + client_name)
				if attached socket.peer_address as client_address then
					-- we must create a new object to insert into the database
					create address.make_from_address_and_port (client_address.host_address, client_address.port)
					success := clients.register (client_name, address)
					if success then
						print(" " + client_address.host_address.host_address + ":" + client_address.port.out + " succeeded")
					else
						-- TODO: what to do here ? send back an error message ?!
						print(" failed")
					end
				else
					print("no valid peer_address")
				end

			else
				print("invalid name_key")
			end

			print("%N")
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
			create key.make_from_string ({UTILS}.message_type_key)
			value := create {JSON_NUMBER}.make_integer ({UTILS}.registered_users_message)
			json_users_answer.put (value, key)

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


			if attached socket.peer_address as address then
				print("send answer to: " + address.host_address.host_address + ":" + address.port.out + "%N")
				socket.send_to (generat_packet (json_users_answer), address, 0)
			else
				--TODO: probably nothing can be done
			end



		end

	handle_query(json_object: JSON_OBJECT)
		local
			key: JSON_STRING
			value: JSON_VALUE
			json_query_answer: JSON_OBJECT
		do
			if attached {JSON_STRING} json_object.item ({UTILS}.name__key) as name then
				if clients.is_client_registered (name.item) and then attached {NETWORK_SOCKET_ADDRESS} clients.query_address (name.item) as peer_address  then

					-- generate response
					create json_query_answer.make

					-- create message type
					create key.make_from_string ({UTILS}.message_type_key)
					value := create {JSON_NUMBER}.make_integer ({UTILS}.query_message)
					json_query_answer.put (value, key)

					-- put the ip_address
					create key.make_from_string ({UTILS}.ip_key)
					value := create {JSON_STRING}.make_from_string (peer_address.host_address.host_address)
					json_query_answer.put (value, key)

					--put the port
					create key.make_from_string ({UTILS}.port_key)
					value := create {JSON_NUMBER}.make_integer (peer_address.port)
					json_query_answer.put (value, key)

					-- generate packet and send back to sender

					if attached socket.peer_address as address then
						print("send answer to: " + address.host_address.host_address + ":" + address.port.out + "%N")
						socket.send_to (generat_packet (json_query_answer), address, 0)
					else
						--TODO: probably nothing can be done
					end

				else
					-- TODO: maybe generate appropriate error message
				end

			else
				-- TODO: maybe generate appropriate error message
			end

		end

	handle_unregister(json_object: JSON_OBJECT)
		do

		end


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

feature {NONE} --data
	utils: UTILS
	socket: NETWORK_DATAGRAM_SOCKET
	clients: CLIENT_DATABASE

end
