note
	description: "Summary description for {TARGET_PACKET}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TARGET_PACKET

inherit
	PACKET

create
	make_register_packet, make_query_packet, make_keep_alive_packet, make_unregister_packet

feature -- INITALIZATION
	make_register_packet(my_name: STRING)
		local
			key: JSON_STRING
			value: JSON_VALUE
			json_object: JSON_OBJECT
		do
			create json_object.make

			-- create message type
			create key.make_from_string ({UTILS}.message_type_key)
			value := create {JSON_NUMBER}.make_integer ({UTILS}.register_message)

			json_object.put (value, key)


			-- create client name
			create key.make_from_string ({UTILS}.name__key)
			value := create {JSON_STRING}.make_from_string (my_name)
			json_object.put (value, key)

			-- fill the packet
			fill(json_object)

			-- set peer_address

			create peer_address.make_from_hostname_and_port ({UTILS}.server_ip, {UTILS}.server_port)
		end

	make_query_packet(peer_name: STRING)
		local
			key: JSON_STRING
			value: JSON_VALUE
			json_object: JSON_OBJECT
		do
			create json_object.make

			-- create message type
			create key.make_from_string ({UTILS}.message_type_key)
			value := create {JSON_NUMBER}.make_integer ({UTILS}.query_message)
			json_object.put (value, key)

			-- create peer_name to query
			create key.make_from_string ({UTILS}.name__key)
			value := create {JSON_STRING}.make_from_string (peer_name)
			json_object.put (value, key)

			-- fill the packet
			fill(json_object)

			-- set peer_address

			create peer_address.make_from_hostname_and_port ({UTILS}.server_ip, {UTILS}.server_port)

		end

	make_keep_alive_packet(a_peer_address: NETWORK_SOCKET_ADDRESS)
		local
			key: JSON_STRING
			value: JSON_VALUE
			json_object: JSON_OBJECT
		do
			create json_object.make

			-- create message type
			create key.make_from_string ({UTILS}.message_type_key)
			value := create {JSON_NUMBER}.make_integer ({UTILS}.keep_alive_message)
			json_object.put (value, key)

			-- fill the packet
			fill(json_object)

			-- set peer_address
			create peer_address.make_from_address_and_port (a_peer_address.host_address, a_peer_address.port)

		end

	make_unregister_packet(my_name: STRING)
		local
			key: JSON_STRING
			value: JSON_VALUE
			json_object: JSON_OBJECT
		do
			create json_object.make

			-- create message type
			create key.make_from_string ({UTILS}.message_type_key)
			value := create {JSON_NUMBER}.make_integer ({UTILS}.unregister_message)
			json_object.put (value, key)


			-- TODO: add other name/value pairs

			-- fill the packet
			fill(json_object)

			-- set peer_address

			create peer_address.make_from_hostname_and_port ({UTILS}.server_ip, {UTILS}.server_port)

		end


	make_application_packet(a_peer_address: NETWORK_SOCKET_ADDRESS message: STRING)
		local
			key: JSON_STRING
			value: JSON_VALUE
			json_object: JSON_OBJECT
		do
			create json_object.make

			-- create message type
			create key.make_from_string ({UTILS}.message_type_key)
			value := create {JSON_NUMBER}.make_integer ({UTILS}.application_message)
			json_object.put (value, key)


			-- TODO: add other name/value pairs

			-- fill the packet
			fill(json_object)

			-- set peer_address

			create peer_address.make_from_address_and_port (a_peer_address.host_address, a_peer_address.port)
		end

feature -- helpers

	fill(json_object: JSON_OBJECT)
		local
			string_rep:  STRING
			i: INTEGER
		do
			string_rep := json_object.representation
			make (string_rep.count)
			from i := 1
			until i > string_rep.count
			loop
				put_element (string_rep.item (i), i-1)
				i := i+1
			end
		end

feature -- TARGET

	peer_address: NETWORK_SOCKET_ADDRESS

end
