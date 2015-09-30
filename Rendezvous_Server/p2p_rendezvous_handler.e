note
	description: "Summary description for {P2P_RENDEZVOUS_HANDLER}."
	date: "$Date$"
	revision: "$Revision$"

class
	P2P_RENDEZVOUS_HANDLER

create
	make

feature {NONE} -- Initialization

	make (a_clients: CLIENT_DATABASE; a_peer_address: like peer_address; a_logger: P2P_RENDEZVOUS_LOGGER; a_packet_sender: like packet_sender)
		do
			logger := a_logger
			clients := a_clients
			peer_address := a_peer_address
			packet_sender := a_packet_sender
		end

feature -- Access

	packet_sender: PROCEDURE [ANY, TUPLE [PACKET, NETWORK_SOCKET_ADDRESS]]
			-- Packet sender agent.

	peer_address: NETWORK_SOCKET_ADDRESS

	logger: P2P_RENDEZVOUS_LOGGER

	clients: CLIENT_DATABASE

feature -- Execution

	execute (json_object: JSON_OBJECT)
 		local
 			type: INTEGER_64
 			m: STRING
 		do
 			if attached {JSON_NUMBER} json_object.item ({P2P_PROTOCOL_CONSTANTS}.message_type_key) as type_number then
 				type := type_number.integer_64_item
 			 	m := "Message is of type: " + type.out + " which means "

 			 	inspect type
 			 	when {P2P_PROTOCOL_CONSTANTS}.register_message then
 			 		m.append ("register message.")
					handle_register (json_object)
 			 	when {P2P_PROTOCOL_CONSTANTS}.query_message then
 			 		m.append ("query message.")
					handle_query (json_object)
 			 	when {P2P_PROTOCOL_CONSTANTS}.unregister_message then
 			 		m.append ("unregister message.")
					handle_unregister (json_object)
				when {P2P_PROTOCOL_CONSTANTS}.registered_users_message then
					m.append ("registered_users message.")
					handle_registered_users
 			 	else
 			 		m.append ("invalid type.")
 			 	end
 			 	logger.put_debug (m)
 			else
 				logger.put_error ("Message is invalid (no type).")
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
			put_type_into_json (json_register_answer, {P2P_PROTOCOL_CONSTANTS}.register_message)

				-- put no error, might be replaced
			replace_error_in_json (json_register_answer, {P2P_PROTOCOL_CONSTANTS}.no_error)

				-- get the name
			if attached {JSON_STRING} json_object.item ({P2P_PROTOCOL_CONSTANTS}.name_key) as name then
				client_name := name.item
				logger.put_debug ("register: " + client_name)
					-- we must create a new object to insert into the database
				create address.make_from_address_and_port (peer_address.host_address, peer_address.port)
				clients.register (client_name, address)
				if clients.has_error then
					if attached clients.last_error_message as err then
						logger.put_debug (" -> " + err)
					end
					replace_error_in_json (json_register_answer, clients.last_error_code)
				else
					logger.put_debug (" -> " + address.host_address.host_address + ":" + address.port.out + " succeeded")
				end
			else
				logger.put_debug ("Invalid name_key")
			end

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
			put_type_into_json (json_unregister_answer, {P2P_PROTOCOL_CONSTANTS}.unregister_message)

				-- put no error, might be replaced
			replace_error_in_json (json_unregister_answer, {P2P_PROTOCOL_CONSTANTS}.no_error)

				-- get the name
			if attached {JSON_STRING} json_object.item ({P2P_PROTOCOL_CONSTANTS}.name_key) as name then
				client_name := name.item
				logger.put_debug ("unregister: " + client_name)
				clients.unregister (client_name, peer_address)
				if clients.has_error then
					if attached clients.last_error_message as err then
						logger.put_debug (" -> " + err)
					end
					replace_error_in_json (json_unregister_answer, clients.last_error_code)
				else
					logger.put_debug (" -> success, name and ip match")
				end
			else
				logger.put_debug (" -> invalid name_key")
			end

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
			put_type_into_json (json_users_answer, {P2P_PROTOCOL_CONSTANTS}.registered_users_message)

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
			put_type_into_json (json_query_answer, {P2P_PROTOCOL_CONSTANTS}.query_message)

				-- put unknown error, might be replaced
			replace_error_in_json (json_query_answer, {P2P_PROTOCOL_CONSTANTS}.unknown_error)

				-- get the name
			if attached {JSON_STRING} json_object.item ({P2P_PROTOCOL_CONSTANTS}.name_key) as name then
				if clients.is_client_registered (name.item) then
					if attached clients.peer_address (name.item) as client_address  then
						logger.put_debug (" -> IP of " + name.item + " is : " + client_address.host_address.host_address + ":" + client_address.port.out)

							-- put the error type
						replace_error_in_json (json_query_answer, {P2P_PROTOCOL_CONSTANTS}.no_error)

							-- put the ip_address
						put_string_into_json (json_query_answer, {P2P_PROTOCOL_CONSTANTS}.ip_key, client_address.host_address.host_address)

							-- put the port
						put_integer_into_json (json_query_answer, {P2P_PROTOCOL_CONSTANTS}.port_key, client_address.port)
					end
				else
						-- put error
					replace_error_in_json (json_query_answer, {P2P_PROTOCOL_CONSTANTS}.client_not_registered)
					logger.put_debug (" -> query failed, no such registered user " + name.item)
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
			packet_sender.call ([new_packet (json_object), peer_address])
		end

feature {NONE} -- JSON helpers		

	put_string_into_json (json_object: JSON_OBJECT; a_key: STRING; a_value: STRING)
		do
			json_object.put_string (a_value, a_key)
		end

	put_integer_into_json (json_object: JSON_OBJECT; a_key: STRING; a_value: INTEGER_64)
		do
			json_object.put_integer (a_value, a_key)
		end

	put_type_into_json (json_object: JSON_OBJECT; type: INTEGER_64)
		do
			put_integer_into_json (json_object, {P2P_PROTOCOL_CONSTANTS}.message_type_key, type)
		end

	replace_error_in_json (json_object: JSON_OBJECT; error: INTEGER_64)
			-- if not present it will be inserted
		do
			json_object.replace_with_integer (error, {P2P_PROTOCOL_CONSTANTS}.error_type_key)
		end


end
