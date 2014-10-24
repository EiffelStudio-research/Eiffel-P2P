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
	make_from_packet
feature
	make_from_packet(packet: MY_PACKET)
		do
--			if
--				attached data as network_address
--			then
--				n_addr := network_address

--			else
--				create n_addr.make_localhost (-1)
--			end
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
--			mapped_addr: MY_ATTRIBUTE
--			attr_value: MY_PACKET
--			mapped_ip: NATURAL_32
--			mapped_port: NATURAL_16
--			response_message: MESSAGE
--		do
--			create RESULT.make_empty
--			response_protocol := my_message.protocol
--			response_method := my_message.method
--			response_cookie := my_message.magic_cookie
--			response_transaction_id := my_message.transaction_id
--			inspect
--				my_message.message_class
--			when 0 then
--				inspect
--					my_message.method
--				when 1 then
--					create RESULT.make_empty
--				else
--					create RESULT.make_empty
--				end
--			else
--				create RESULT.make_empty
--			end
--		end
--	generate_action: ACTION
--		do
--			create RESULT.make_no_action
--			action_notified := true
--		end
	generate_feedback: FEEDBACK
		local
			status: INTEGER
			comment: STRING
			data: ARRAY[NATURAL_8]
		do
			status := 0
			comment := "This packet is using STUN protocol!"
			create data.make_empty
			create RESULT.make (status, comment, data)
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
