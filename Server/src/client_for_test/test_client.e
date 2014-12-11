note
	description : "client_for_test application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	TEST_CLIENT

inherit
	ARGUMENTS
	SOCKET_RESOURCES

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			soc1: detachable NETWORK_STREAM_SOCKET
			addr: NETWORK_SOCKET_ADDRESS
		do
			print("testing!")
			create soc1.make_client_by_port (8888, "localhost")
			create addr.make_any_local (9999)
			soc1.set_address (addr)
			soc1.bind
			soc1.connect


			process(soc1)


			soc1.cleanup



		rescue
            if soc1 /= Void then
                soc1.cleanup
            end
		end
	process(soc1: detachable NETWORK_STREAM_SOCKET)
		require
			socket_not_void: soc1 /= Void
		local
			pkt: MY_PACKET
			msg: MESSAGE
			test_protocol: INTEGER
			test_class: INTEGER
			test_method: INTEGER
			test_magic_cookie: ARRAY[NATURAL_8]
			test_transaction_id: ARRAY[NATURAL_8]
			test_attr: MY_ATTRIBUTE
			test_required_attributes: ARRAY[MY_ATTRIBUTE]
			test_optional_attributes: ARRAY[MY_ATTRIBUTE]
			response_message: MESSAGE
		do
			test_protocol := 0
			test_class := 0
			test_method := 1
			create test_magic_cookie.make_filled (0, 0, 3)
			test_magic_cookie.at (0) := 0x21
			test_magic_cookie.at (1) := 0x12
			test_magic_cookie.at (2) := 0xA4
			test_magic_cookie.at (3) := 0x42
			create test_transaction_id.make_filled (0xF0, 0, 11)
			create test_required_attributes.make_empty
			create test_optional_attributes.make_empty
			create msg.make (test_protocol, test_method, test_class, test_magic_cookie, test_transaction_id, test_required_attributes, test_optional_attributes)
			pkt := msg.generate_packet
			pkt.independent_store (soc1)
			if attached {MY_PACKET} pkt.retrieved (soc1) as packet then
				response_message := packet.generate_message
				print ("Protocol: ")
				print (response_message.protocol)
				print ("Class: ")
				print (response_message.message_class)
				print ("Method: ")
				print (response_message.method)
				print ("Magic cookie: ")
				print (response_message.magic_cookie.at (0).to_hex_string)
				print (response_message.magic_cookie.at (1).to_hex_string)
				print (response_message.magic_cookie.at (2).to_hex_string)
				print (response_message.magic_cookie.at (3).to_hex_string)
				print ("Transaction id: ")
				print (response_message.transaction_id.at (0).to_hex_string)
				print (response_message.transaction_id.at (1).to_hex_string)
				print (response_message.transaction_id.at (2).to_hex_string)
				print (response_message.transaction_id.at (3).to_hex_string)
				print (response_message.transaction_id.at (4).to_hex_string)
				print (response_message.transaction_id.at (5).to_hex_string)
				print (response_message.transaction_id.at (6).to_hex_string)
				print (response_message.transaction_id.at (7).to_hex_string)
				print (response_message.transaction_id.at (8).to_hex_string)
				print (response_message.transaction_id.at (9).to_hex_string)
				print (response_message.transaction_id.at (10).to_hex_string)
				print (response_message.transaction_id.at (11).to_hex_string)
				print ("Attribute name: ")
				print (response_message.comprehension_required_attributes.at (0).attribute_name)

			end

		end

end
