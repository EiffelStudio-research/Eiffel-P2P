note
	description: "Summary description for {STUN_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STUN_HANDLER

inherit
	PROTOCOL_HANDLER
create
	make_from_packet_and_data
feature
	make_from_packet_and_data(packet: MY_PACKET data: detachable NETWORK_SOCKET_ADDRESS)
		do
			if
				attached data as network_address
			then
				n_addr := network_address
				
			else
				create n_addr.make_localhost (-1)
			end
			create h_parser.make_from_packet (packet)
			create b_parser.make_from_packet (packet)
			my_message := packet.generate_message
		end
	generate_response(action_done: BOOLEAN record_list: MY_RECORD_LIST): MY_PACKET
		local
			response_protocol: INTEGER
			response_class: INTEGER
			response_method: INTEGER
			response_length: INTEGER
			response_cookie: ARRAY[NATURAL_8]
			response_transaction_id: ARRAY[NATURAL_8]
			required_attributes: ARRAY[MY_ATTRIBUTE]
			optional_attributes: ARRAY[MY_ATTRIBUTE]
			mapped_addr: MY_ATTRIBUTE
			attr_value: MY_PACKET
			mapped_ip: NATURAL_32
			mapped_port: NATURAL_16
			response_message: MESSAGE
		do
			create RESULT.make_empty
			response_protocol := my_message.protocol
			response_method := my_message.method
			response_cookie := my_message.magic_cookie
			response_transaction_id := my_message.transaction_id
			inspect
				my_message.message_class
			when 0 then
				inspect
					my_message.method
				when 1 then
					response_class := 2
					response_length := 12
					create attr_value.make_filled (0, 0, 7)
					mapped_ip := n_addr.host_address.ipv4.as_natural_32
					mapped_port := n_addr.port.as_natural_16
					attr_value.at (0) := 0
					attr_value.at (1) := 1
					attr_value.put_in_natural_16 (mapped_port, 2)
					attr_value.put_in_natural_32 (mapped_ip, 4)
					create mapped_addr.make (1, attr_value)
					create required_attributes.make_filled (mapped_addr, 0, 0)
					create optional_attributes.make_empty
					create response_message.make (response_protocol, response_method, response_class, response_cookie, response_transaction_id, required_attributes, optional_attributes)
					RESULT := response_message.generate_packet
				else
					create RESULT.make_empty
				end
			else
				create RESULT.make_empty
			end
		end
	generate_action: ACTION
		do
			create RESULT.make_no_action
			action_notified := true
		end
	is_known: BOOLEAN
		do
			RESULT := true
		end
	validate_message: BOOLEAN
		do
			RESULT := validate_magic_cookie and then validate_method and then validate_class
		end
feature {NONE}
	my_message: MESSAGE
	h_parser: HEADER_PARSER
	b_parser: BODY_PARSER
	n_addr: NETWORK_SOCKET_ADDRESS
	validate_magic_cookie: BOOLEAN
		local
			magic_cookie: ARRAY[NATURAL_8]
		do
			magic_cookie := h_parser.get_magic_cookie
			RESULT := magic_cookie.at (0) = 0x21 and magic_cookie.at (1) = 0x12 and magic_cookie.at (2) = 0xA4 and magic_cookie.at (3) = 0x42
		end
	validate_method: BOOLEAN
		do
			RESULT := h_parser.get_method = 1
		end
	validate_class: BOOLEAN
		local
			m_class: INTEGER
		do
			m_class := h_parser.get_class
			RESULT := m_class = 0 or else m_class = 1
		end
end
