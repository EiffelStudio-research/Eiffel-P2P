note
	description : "client_interface application root class"
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
		local
			con:CONNECTION_MANAGER
		do

		--	create con.make
		--	con.udp_hole_punch ("127.0.0.1", 3400, 3400)
			print ("Hello Eiffel World!%N")
		end

	test_send
		local
			soc: NETWORK_DATAGRAM_SOCKET
			pac: PACKET
			i: INTEGER
			t: TIME
			send_string : STRING
			send_json:JSON_OBJECT

			key: JSON_STRING
			value: JSON_VALUE


		do
			--| Add your code here
			print ("Hello Eiffel World!%N")
			create soc.make_targeted ("188.63.191.24", 8888)
--			create pac.make (10)
--			soc.send (pac, 0)
--			print ("Packet sent")

			create send_json.make
			create key.make_from_string ("type")

			send_json.put_integer (1, key)

			print("Picked up a JSON Object to send")
			send_string := send_json.representation
			print("This is the sens String: " + send_string)

			create pac.make (send_string.count)
			from i := 1
			until i > send_string.count
			loop
				pac.put_element (send_string.item (i), i)
			end
			print("Finished parsing to char")

			create t.make_now
			soc.send (pac, 0)
		--	soc.independent_store (pac)

			print("Sent packet " + send_string  + " " + t.out + "%N")
		end

end
