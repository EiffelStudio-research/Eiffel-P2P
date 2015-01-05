note
	description : "ewfp2pclient application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	P2PCLIENT

inherit
	ARGUMENTS
	SOCKET_RESOURCES
	STORABLE

create
	make


-- register 188.63.191.24 8888 40011
-- connect 188.63.191.24 40002
feature {NONE} -- Initialization

	make
			-- Run application.
		local

			user_command: STRING
			command_parser: COMMAND_PARSER


			my_port: INTEGER
			server_port: INTEGER
			server_ip: STRING

		do
			print ("Hello Eiffel World!%N")
			create packet_processor.make
			create message_processor.make
			create conn_manag.make
			state := 0
			create id.make_empty
			create key.make_empty
			my_local_port := -1;
			from
				user_command := get_user_command
				create command_parser.make_from_command (user_command)
			until
				command_parser.method.is_case_insensitive_equal ("exit")
			loop
				if
					command_parser.method.is_case_insensitive_equal ("register")
				then
					my_port := command_parser.params.at (2).to_integer_32
					server_port := command_parser.params.at (1).to_integer_32
					server_ip := command_parser.params.at (0)

					if
						conn_manag.connect_to_server (server_ip, server_port, my_port)
					then
						process(conn_manag.main_tcp_soc, command_parser)
						conn_manag.cleanup_connection
					end

				elseif
					command_parser.method.is_case_insensitive_equal ("query")
				then
					server_port := command_parser.params.at (1).to_integer_32
					server_ip := command_parser.params.at (0)
					if
						conn_manag.connect_to_server_any_port (server_ip, server_port)
					then
						process(conn_manag.main_tcp_soc, command_parser)
						conn_manag.cleanup_connection
					end

				elseif
					command_parser.method.is_case_insensitive_equal ("connect")
				then
					my_port := command_parser.params.at (2).to_integer_32
					server_port := command_parser.params.at (1).to_integer_32 -- actually it is the peer port
					server_ip := command_parser.params.at (0)	-- actually it is the peer ip


					conn_manag.udp_hole_punch (server_ip, server_port, my_port)


--					if conn_manag.tcp_hole_punch (server_ip, server_port, my_port) then

--				end

					conn_manag.cleanup_connection

				end
				print("----------------------------------------------------------------------")
				print("%N")
				user_command := get_user_command

				create command_parser.make_from_command (user_command)

			end
		end

	process(soc1: detachable NETWORK_STREAM_SOCKET command: COMMAND_PARSER)


		require
			socket_not_void: soc1 /= Void

		local
			pkt: MY_PACKET
			msg: MESSAGE
			user_command: STRING
			protocol_handler: PROTOCOL_HANDLER
			current_response: MY_PACKET
			command_parser: COMMAND_PARSER
			magic_cookie: ARRAY[NATURAL_8]
			transaction_id: ARRAY[NATURAL_8]
			identification: ARRAY[NATURAL_8]
			current_attribute: MY_ATTRIBUTE
			comprehension_required_attributes: ARRAY [MY_ATTRIBUTE]
			comprehension_optional_attributes: ARRAY [MY_ATTRIBUTE]
			feedback: FEEDBACK
			addr: detachable NETWORK_SOCKET_ADDRESS

		do



			magic_cookie := generate_magic_cookie
			transaction_id := generate_transaction_id
			create comprehension_required_attributes.make_empty
			create comprehension_optional_attributes.make_empty
			create msg.make_invalid
			if
				command.method.is_case_insensitive_equal ("register")
			then

				identification := generate_identification
				id := identification
				create current_attribute.make (0x22, identification)
				comprehension_required_attributes.force (current_attribute, 0)
				create msg.make (3, 2, 0, magic_cookie, transaction_id, comprehension_required_attributes, comprehension_optional_attributes)
				pkt := msg.generate_packet
				pkt.independent_store (soc1)



				print("Register request sent with id = " + convert_id_to_string(identification) + " .%N")
				if attached {MY_PACKET} pkt.retrieved (soc1) as packet then
					print("A packet received!")
--					addr := soc1.address
--					if
--						addr /= Void
--					then
--						my_local_port := addr.port
--						print("Local port is " + addr.host_address.host_address + ".%N")
--					end

					protocol_handler := packet_processor.process_packet(packet)
					feedback := message_processor.generate_feedback (protocol_handler)
					if
						feedback.get_status = 0
					then
						state := 3
						key := feedback.get_data
					end
					print_feedback(feedback.get_comment, feedback.get_status)
				end
			elseif
				command.method.is_case_insensitive_equal ("query")
			then
--				identification := convert_string_to_id(command.params.at (2))
				identification := convert_string_to_id(convert_id_to_string(id))

				create current_attribute.make (0x22, identification)
				comprehension_required_attributes.force (current_attribute, 0)
				create msg.make (3, 4, 0, magic_cookie, transaction_id, comprehension_required_attributes, comprehension_optional_attributes)
				pkt := msg.generate_packet
				pkt.independent_store (soc1)



				if attached {MY_PACKET} pkt.retrieved (soc1) as packet then
					print("A packet received!")
					protocol_handler := packet_processor.process_packet(packet)
					feedback := message_processor.generate_feedback (protocol_handler)
					if
						feedback.get_status = 0
					then
						state := 3
						key := feedback.get_data
					end
					print_feedback(feedback.get_comment, feedback.get_status)
				end
			end


		rescue
			print ("Server disconnected!%N")
            if soc1 /= Void then
                soc1.cleanup
            end

		end
	packet_processor: PACKET_PROCESS_MODULE
	message_processor: MESSAGE_PROCESS_MODULE
	state: INTEGER
	id: ARRAY[NATURAL_8]
	key: ARRAY[NATURAL_8]
	my_local_port: INTEGER

	conn_manag: CONNECTION_MANAGER

	get_user_command: STRING
		local
			user_command:STRING
		do
			from
				io.read_line
				user_command := io.last_string
				user_command.trim
			until
				not user_command.is_equal ("")
			loop
				io.read_line
				user_command := io.last_string
				user_command.trim
			end
			RESULT := user_command
		end
	print_feedback(feedback: STRING status:INTEGER)
		do
			if
				status = 0
			then
				io.put_string ("Success: " + feedback)
			elseif
				status = 1
			then
				io.put_string ("Failure: " + feedback)
			elseif
				status = 2
			then
				io.put_string ("Error: " + feedback)
			end
			io.put_new_line
		end
	generate_magic_cookie: ARRAY[NATURAL_8]
		do
			create RESULT.make_filled (0, 0, 3)
			RESULT.put (0x21, 0)
			RESULT.put (0x12, 1)
			RESULT.put (0xA4, 2)
			RESULT.put (0x42, 3)
		end
	generate_transaction_id: ARRAY[NATURAL_8]
		local
			i: INTEGER
			random_generator: RANDOM
			current_time: TIME
			current_byte: INTEGER
		do
			create RESULT.make_filled (0, 0, 11)
			create random_generator.make
			create current_time.make_now
			random_generator.set_seed (current_time.compact_time)

			from
				i := 0
				random_generator.start
			until
				i = 12
			loop
				current_byte := random_generator.item // 256
				RESULT.put(current_byte.to_natural_8, i)
				random_generator.forth
				i := i + 1
			end
		end

	generate_identification: ARRAY[NATURAL_8]
		local
			i: INTEGER
			random_generator: RANDOM
			current_time: TIME
			current_byte: INTEGER
		do
			create RESULT.make_filled (0, 0, 15)
			create random_generator.make
			create current_time.make_now
			random_generator.set_seed (current_time.compact_time)

			from
				i := 0
				random_generator.start
			until
				i = 16
			loop
				current_byte := random_generator.item // 256
				RESULT.put(current_byte.to_natural_8, i)
				random_generator.forth
				i := i + 1
			end
		end
	convert_id_to_string(from_id: ARRAY[NATURAL_8]): STRING
		require
			valid_id_length: from_id.count = 16
		local
			i: INTEGER
			j: INTEGER
			current_section: NATURAL_64
		do
			from
				i := 0
				RESULT := ""
			until
				i = 2
			loop
				current_section := 0

				from
					j := 0
				until
					j = 8
				loop
					current_section := current_section + from_id.at (i * 8 + j).as_natural_64.bit_shift_left ((7 - j) * 8)
					j := j + 1
				end
				RESULT := RESULT + current_section.out
				RESULT := RESULT + "-"
				i := i + 1
			end
			RESULT.remove_tail (1)
		end
	convert_string_to_id(from_string: STRING): ARRAY[NATURAL_8]
		local
			id_in_sections: LIST[STRING]
			i: INTEGER
			j: INTEGER
			current_section: NATURAL_64
		do
			from_string.trim
			id_in_sections := from_string.split ('-')
			create RESULT.make_filled (0, 0, 15)
			from
				i := 0
				id_in_sections.start
			until
				id_in_sections.after or i = 2
			loop
				current_section := id_in_sections.item.to_natural_64
				from
					j := 0
				until
					j = 8
				loop
					RESULT.put (current_section.bit_shift_right ((7 - j) * 8).bit_and (0x000000000000000000000000000000FF).as_natural_8, i * 8 + j)
					j := j + 1
				end
				id_in_sections.forth
				i := i + 1
			end
		end




	server_listen(socket: detachable NETWORK_STREAM_SOCKET)
		require
			socket_not_void: socket /= Void
		local
			count: INTEGER

		do

			socket.listen (10)
			from
				count := 0
			until
				count = 5
			loop
				print("Start listening on port " + socket.port.out + "%N")
				server_process(socket)
			end
			socket.cleanup

		rescue
			if socket /= Void then
				print("hehehehhe%N")
				socket.cleanup
			end
		end

	server_process(soc: detachable NETWORK_STREAM_SOCKET)
		require
			soc_not_void: soc /= Void
		do
			soc.accept
			if attached soc.accepted as soc2 then
				print("A client connected!%N")
				if attached {MY_STRING} retrieved (soc2) as packet then
					print("A message received!%N")
					print("The message is " + packet.message + ".%N")
					packet.independent_store (soc2)
				end
			end
			print("Client disconnected!%N")
		rescue
			print("unknow exception happens%N")
		end

	client_process(soc: detachable NETWORK_STREAM_SOCKET)
		require
			soc_not_void: soc /= Void
		local
			message: MY_STRING
			message_string: STRING
		do
			print("Enter a message to your peer.%N")
			message_string := get_user_command
			create message.make_from_string (message_string)
			message.independent_store (soc)
			if attached {MY_STRING} message.retrieved (soc) as response then
				print("A reply received!%N")
				print("Reply is " + response.message + ".%N")
			end
		end
end
