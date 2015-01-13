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
	make_register_packet, make_query_packet, make_keep_alive_packet, make_unregister_packet,
	make_application_packet,make_registered_users_packet , make_hole_punch_packet

feature -- INITALIZATION
	make_register_packet(my_name: STRING)
		do
			create json_object.make

			-- create message type
			put_type ({UTILS}.register_message)

			-- create client name
			put_string ({UTILS}.name__key, my_name)

			-- fill the packet
			fill

			-- set peer_address
			create peer_address.make_from_hostname_and_port ({UTILS}.server_ip, {UTILS}.server_port)
		end

	make_query_packet(peer_name: STRING)
		do
			create json_object.make

			-- create message type
			put_type ({UTILS}.query_message)

			-- create peer_name to query
			put_string ({UTILS}.name__key, peer_name)

			-- fill the packet
			fill

			-- set peer_address
			create peer_address.make_from_hostname_and_port ({UTILS}.server_ip, {UTILS}.server_port)

		end

	make_keep_alive_packet(a_peer_address: NETWORK_SOCKET_ADDRESS)
		do
			create json_object.make

			-- create message type
			put_type ({UTILS}.keep_alive_message)

			-- fill the packet
			fill

			-- set peer_address
			create peer_address.make_from_address_and_port (a_peer_address.host_address, a_peer_address.port)

		end

	make_unregister_packet(my_name: STRING)
		local
			key: JSON_STRING
			value: JSON_VALUE

		do
			create json_object.make

			-- create message type
			put_type ({UTILS}.unregister_message)

			-- create client name
			put_string ({UTILS}.name__key, my_name)

			-- fill the packet
			fill

			-- set peer_address
			create peer_address.make_from_hostname_and_port ({UTILS}.server_ip, {UTILS}.server_port)

		end


	make_application_packet(a_peer_address: NETWORK_SOCKET_ADDRESS message: STRING)
		local
			key: JSON_STRING
			value: JSON_VALUE

		do
			create json_object.make

			-- create message type
			put_type ({UTILS}.application_message)

			-- create message
			put_string ({UTILS}.data_key, message)

			-- fill the packet
			fill

			-- set peer_address
			create peer_address.make_from_address_and_port (a_peer_address.host_address, a_peer_address.port)
		end

	make_registered_users_packet
		local
			key: JSON_STRING
			value: JSON_VALUE

		do
			create json_object.make

			-- create message type	
			put_type ({UTILS}.registered_users_message)

			-- fill the packet
			fill

			-- set peer_address
			create peer_address.make_from_hostname_and_port ({UTILS}.server_ip, {UTILS}.server_port)
		end

	make_hole_punch_packet(a_peer_address: NETWORK_SOCKET_ADDRESS)
		local
			key: JSON_STRING
			value: JSON_VALUE
		do
			create json_object.make

			-- create message type
			put_type ({UTILS}.hole_punch_message)

			-- fill the packet
			fill

			-- set peer_address
			create peer_address.make_from_address_and_port (a_peer_address.host_address, a_peer_address.port)

		end


feature -- helpers

	fill
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

	put_string(key: STRING value: STRING)
		local
			j_key: JSON_STRING
			j_value: JSON_STRING
		do
			create j_key.make_from_string (key)
			create j_value.make_from_string (value)
			json_object.put (j_value, j_key)
		end

	put_integer( key: STRING value: INTEGER_64)
		local
			j_key: JSON_STRING
			j_value: JSON_NUMBER
		do
			create j_key.make_from_string (key)
			create j_value.make_integer (value)
			json_object.put (j_value, j_key)
		end

	put_type(type: INTEGER_64)
		do
			put_integer({UTILS}.message_type_key, type)
		end

feature -- DATA

	json_object: JSON_OBJECT

feature -- TARGET

	peer_address: NETWORK_SOCKET_ADDRESS

end
