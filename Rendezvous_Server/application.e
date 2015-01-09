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
 			create key.make_from_string ("type")

 			value := json_object.item (key)
 			if attached {JSON_NUMBER} value as type_number then
 				type := type_number.integer_64_item
 			 	print("Message is of type: " + type.out + " which means")

 			 	inspect type
 			 	when 1 then
 			 		print("register message %N")
					handle_register(json_object)
 			 	when 2 then
 			 		print("query message %N")
					handle_query(json_object)
 			 	when 3 then
 			 		print("unregister message %N")
					handle_unregister(json_object)
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

					success := clients.register (client_name, client_address)
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
				print("invalid name_key %N")
			end

		end

	handle_query(json_object: JSON_OBJECT)
		do

		end

	handle_unregister(json_object: JSON_OBJECT)
		do

		end

feature {NONE} --data
	utils: UTILS
	socket: NETWORK_DATAGRAM_SOCKET
	clients: CLIENT_DATABASE

end
