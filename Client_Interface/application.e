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
			con: CONNECTION_MANAGER

		do

			print ("Hello Eiffel World!%N")
			create con.make

			con.start

			con.register ("Bob")
			con.connect ("Silvan")

--			con.sleep (4000000000)
			con.stop
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

			type: STRING_32


		do
			--| Add your code here

			print ("Hello Eiffel World!%N")
			create soc.make_targeted ("188.63.191.24", 8888)
--			create pac.make (10)
--			soc.send (pac, 0)
--			print ("Packet sent")

			create send_json.make
			create type.make_from_string ("type")
			create key.make_from_string_32 (type)

			send_json.put_string ("hallo", key)

			print("Picked up a JSON Object to send")
			send_string := send_json.representation
			print("This is the sens String: " + send_string)

			create pac.make (send_string.count)
			from i := 1
			until i > send_string.count
			loop
				pac.put_element (send_string.item (i), i-1)
				i := i + 1
			end
			print("Finished parsing to char")

			create t.make_now
			soc.send (pac, 0)
		--	soc.independent_store (pac)

			print("Sent packet " + send_string  + " " + t.out + "%N")

		end

end
