note
	description: "Summary description for {EP}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EP_HANDLER

inherit
	PROTOCOL_HANDLER
create
	make_from_packet

feature
	make_from_packet(packet: MY_PACKET)
		do
			create h_parser.make_from_packet (packet)
			create b_parser.make_from_packet (packet)
			my_message := packet.generate_message
		end
--	generate_response(action_done: BOOLEAN record_list: MY_RECORD_LIST): MY_PACKET
--		local
--			response_protocol: INTEGER
--			response_class: INTEGER
--			response_method: INTEGER
--			response_length: INTEGER
--			response_cookie: ARRAY[NATURAL_8]
--			response_transaction_id: ARRAY[NATURAL_8]
--			required_attributes: ARRAY[MY_ATTRIBUTE]
--			optional_attributes: ARRAY[MY_ATTRIBUTE]
--			error_reason: MY_ATTRIBUTE
--			queried_addr: MY_ATTRIBUTE
--			new_key: MY_ATTRIBUTE
--			attr_value: MY_PACKET
--			queried_ip: NATURAL_32
--			queried_port: NATURAL_16
--			response_message: MESSAGE
--			queried_record: MY_RECORD
--		do
--			print("EP handler is generating response!%N")
--			create RESULT.make_empty
--			response_protocol := my_message.protocol
--			response_method := my_message.method
--			response_cookie := my_message.magic_cookie
--			response_transaction_id := my_message.transaction_id
--			if
--				action_done
--			then

--				inspect
--					my_message.message_class
--				when 0 then
--					inspect
--						my_message.method
--					when 2 then
--						response_class := 2
--						response_length := 12
--						create attr_value.make_filled (0, 0, 7)
--						attr_value.put_in_natural_64 (target_record.get_key, 0)
--						create new_key.make (0x0024, attr_value)
--						create required_attributes.make_filled (new_key, 0, 0)
--					when 3 then
--						response_class := 2
--						response_length := 0
--						create required_attributes.make_empty
--					when 4 then
--						queried_record := record_list.find_record (id)
--						if
--							queried_record.is_valid
--						then
--							response_class := 2
--							response_length := 12
--							create attr_value.make_filled (0, 0, 7)
--							queried_ip := queried_record.record_ipv4_addr
--							queried_port := queried_record.record_port.as_natural_16
--							attr_value.at (0) := 0
--							attr_value.at (1) := 1
--							attr_value.put_in_natural_16 (queried_port, 2)
--							attr_value.put_in_natural_32 (queried_ip, 4)
--							create queried_addr.make (1, attr_value)
--							create required_attributes.make_filled (queried_addr, 0, 0)
--						else
--							response_class := 3
--							response_length := 8
--							create attr_value.make_filled (0, 0, 3)
--							attr_value.put_in_natural_32 (2, 0)
--							create error_reason.make (0x0021, attr_value)
--							create required_attributes.make_filled (error_reason, 0, 0)
--						end
--					else
--						response_class := 3
--						response_length := 8
--						create attr_value.make_filled (0, 0, 3)
--						attr_value.put_in_natural_32 (0x00000000, 0)
--						create error_reason.make (0x0021, attr_value)
--						create required_attributes.make_filled (error_reason, 0, 0)
--					end
--				else
--					response_class := 3
--					response_length := 8
--					create attr_value.make_filled (0, 0, 3)
--					attr_value.put_in_natural_32 (0xFFFFFFFF, 0)
--					create error_reason.make (0x0021, attr_value)
--					create required_attributes.make_filled (error_reason, 0, 0)
--				end

--			else
--				response_class := 3
--				response_length := 8
--				create attr_value.make_filled (0, 0, 3)

--				inspect
--					my_message.message_class
--				when 0 then
--					inspect
--						my_message.method
--					when 2 then
--						attr_value.put_in_natural_32 (1, 0)
--					when 3 then
--						attr_value.put_in_natural_32 (3, 0)
--					else
--						attr_value.put_in_natural_32 (2, 0)
--					end
--					create error_reason.make (0x0021, attr_value)
--					create required_attributes.make_filled (error_reason, 0, 0)

--				else
--					attr_value.put_in_natural_32 (0xFFFFFFFF, 0)
--					create error_reason.make (0x0021, attr_value)
--					create required_attributes.make_filled (error_reason, 0, 0)
--				end
--			end
--			create optional_attributes.make_empty
--			create response_message.make (response_protocol, response_method, response_class, response_cookie, response_transaction_id, required_attributes, optional_attributes)
--			RESULT := response_message.generate_packet
--		end
--	generate_action: ACTION
--		do
--			create RESULT.make_no_action
--			if
--				validate_attributes
--			then
--				print("Valid attributes.%N")
--				inspect
--					my_message.message_class
--				when 0 then
--					inspect
--						my_message.method
--					when 2 then
--						create target_record.make_from_id (id)
--						create RESULT.make (0, target_record)
--					when 3 then
--						create target_record.make (id, key, ip_addr, port)
--						create RESULT.make (1, target_record)
--					when 4 then
--						create RESULT.make_no_action
--					else
--						create RESULT.make_no_action
--					end
--				else
--					create RESULT.make_no_action
--				end
--				action_notified := true
--			else
--				create RESULT.make_no_action
--				action_notified := true
--				print("Invalid attributes.%N")
--			end

--		end
	generate_feedback: FEEDBACK
		local
			status: INTEGER
			comment: STRING
			data: ARRAY[NATURAL_8]
			i: INTEGER
		do
			status := 2
			create data.make_empty
			if
				validate_message
			then
				if
					validate_attributes
				then
					inspect
						my_message.message_class
					when 2 then
						inspect
							my_message.method
						when 2 then
							status := 0
							comment := "Client registered!"
							data := my_message.comprehension_required_attributes.at (0).value
						when 3 then
							comment := "TBD"
						when 4 then
							status := 0
							data := my_message.comprehension_required_attributes.at (0).value
							from
								i := 0
							until
								i = data.count
							loop
								print("Data: " + data.at (i).out + ".%N")
								i := i + 1
							end
							comment := "Queried id's network address is: " + fetch_ip_address(data) + ":" + fetch_port_number(data).out
						else
							comment := "Internal error!"
						end
					when 3 then
						inspect
							my_message.method
						when 2 then
							status := 1
							comment := "Client registration failed. Reason: " + current.generate_error_reason (my_message.comprehension_required_attributes.at (0).value)
						when 3 then
							comment := "TBD"
						when 4 then
							comment := "TBD"
						else
							comment := "Internal error!"
						end
					else
						comment := "Internal error!"
					end
				else
					comment := "Invalid EP response with wrong attributes received!"
				end
			else
				comment := "Invalid EP response with wrong class or method received!"
			end
			create RESULT.make (status, comment, data)
		end
	is_known: BOOLEAN
		do
			RESULT := true
		end
	validate_message: BOOLEAN
		do
			RESULT := validate_method and then validate_class
		end
feature {NONE}
	my_message: MESSAGE
	h_parser: HEADER_PARSER
	b_parser: BODY_PARSER
	id: NATURAL_64
	key: NATURAL_64
	ip_addr: NATURAL_32
	port: NATURAL_32
	are_attributes_valid: BOOLEAN
	validate_method: BOOLEAN
		do
			RESULT := h_parser.get_method = 2 or else h_parser.get_method = 3 or else h_parser.get_method = 4
		end
	validate_class: BOOLEAN
		local
			m_class: INTEGER
		do
			m_class := h_parser.get_class
			RESULT := m_class = 2 or m_class = 3
		end
	validate_attributes: BOOLEAN
		local
			length_correctness: BOOLEAN
			attr_1_correctness: BOOLEAN
			attr_2_correctness: BOOLEAN
			attr_3_correctness: BOOLEAN
		do
			inspect
				my_message.method
			when 2 then
				length_correctness := my_message.comprehension_required_attributes.count = 1
				attr_1_correctness := my_message.message_class = 2 and then contain_attribute(my_message.comprehension_required_attributes, 0x0024)
				attr_1_correctness := attr_1_correctness or else (my_message.message_class = 3 and then contain_attribute(my_message.comprehension_required_attributes, 0x0021))
				RESULT := length_correctness and attr_1_correctness
			when 3 then
				length_correctness := my_message.comprehension_required_attributes.count = 3
				attr_1_correctness := contain_attribute(my_message.comprehension_required_attributes, 0x0022)
				attr_2_correctness := contain_attribute(my_message.comprehension_required_attributes, 0x0001)
				attr_3_correctness := contain_attribute(my_message.comprehension_required_attributes, 0x0024)
				RESULT := length_correctness and then attr_1_correctness and then attr_2_correctness and then attr_3_correctness
			when 4 then
				length_correctness := my_message.comprehension_required_attributes.count = 1
				attr_1_correctness := my_message.message_class = 2 and then contain_attribute(my_message.comprehension_required_attributes, 0x0023)
				attr_1_correctness := attr_1_correctness or else (my_message.message_class = 3 and then contain_attribute(my_message.comprehension_required_attributes, 0x0021))
				RESULT := length_correctness and attr_1_correctness
			else
				RESULT := false
			end
		end
	contain_attribute(attributes_list: ARRAY[MY_ATTRIBUTE] target_attribute_name: NATURAL_16): BOOLEAN
		local
			i: INTEGER
			j: INTEGER
		do

			from
				i := 0
			until
				RESULT or else i = attributes_list.count
			loop
				print("This attribute name is " + attributes_list.at (i).attribute_name.to_hex_string + ".%N")
				RESULT := attributes_list.at (i).attribute_name = target_attribute_name
				if
					RESULT
				then
					inspect
						target_attribute_name
					when 0x0022 then
						from
							id := 0
							j := 0
						until
							j = 8
						loop
							id := id.bit_or (attributes_list.at (i).value[j].as_natural_64.bit_shift_left (8 * (7 - j)))
							j := j + 1
						end
					when
						0x0001
					then
						from
							port := 0
							j := 0
						until
							j = 2
						loop
							port := port.bit_or (attributes_list.at (i).value[2 + j].as_natural_32.bit_shift_left (8 * (1 - j)))
							j := j + 1
						end
						from
							ip_addr := 0
							j := 0
						until
							j = 4
						loop
							ip_addr := ip_addr.bit_or (attributes_list.at (i).value[4 + j].as_natural_32.bit_shift_left (8 * (3 - j)))
							j := j + 1
						end

					when
						0x0024
					then
						from
							key := 0
							j := 0
						until
							j = 8
						loop
							key := key.bit_or (attributes_list.at (i).value[j].as_natural_64.bit_shift_left (8 * (7 - j)))
							j := j + 1
						end
					else

					end
				end
				i := i + 1
			end
		end

	fetch_port_number(value: ARRAY[NATURAL_8]):NATURAL_32
		local
			i: INTEGER
		do
			from
				RESULT := 0
				i := 0
			until
				i = 4
			loop
				RESULT := RESULT + value.at (i).as_natural_32.bit_shift_left ((3 - i) * 8)
				i := i + 1
			end
		end

	fetch_ip_address(value: ARRAY[NATURAL_8]):STRING
		local
			i: INTEGER
		do
			from
				RESULT := ""
				i := 0
			until
				i = 4
			loop
				RESULT := RESULT + value.at (i + 4).out
				RESULT := RESULT + "."
				i := i + 1
			end
			RESULT.remove_tail (1)
		end
end
