note
	description: "Summary description for {PACKET_PROCESS_MODULE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PACKET_PROCESS_MODULE
create
	make

feature {ANY}
	make
		do
			create p_validator
		end
	process_packet(packet: MY_PACKET): PROTOCOL_HANDLER
		local
			protocol: INTEGER
			s_handler: STUN_HANDLER
			e_handler: EP_HANDLER
			u_handler: UNKNOWN_HANDLER
			h_parser: HEADER_PARSER
		do
			print("Packet processor started processing a packet.%N")
			packet.rebase (0)
			create h_parser.make_from_packet (packet)
			if
				not p_validator.validate_packet (packet)
			then
				print("Packet not validated!%N")
				create u_handler
				RESULT := u_handler

				print("An UNKNOWN handler is returned!%N")
			else
				print("Packet validated!%N")
				protocol := h_parser.demultiplex
				if
					protocol = 0
				then
					create s_handler.make_from_packet(packet)
					RESULT := s_handler
				elseif
					protocol = 1
				then
					print("An EP handler is returned!%N")
					create e_handler.make_from_packet(packet)
					RESULT := e_handler
				else
					create u_handler
					RESULT := u_handler
				end
			end
		end
feature {NONE}
	p_validator: PACKET_VALIDATOR
end
