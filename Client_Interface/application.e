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
			--| Add your code here
			create con.make
			con.udp_hole_punch ("127.0.0.1", 3400, 3400)
			print ("Hello Eiffel World!%N")
		end

	test_send
		local
			soc: NETWORK_DATAGRAM_SOCKET
			pac: PACKET

		do
			--| Add your code here
			print ("Hello Eiffel World!%N")
			create soc.make_targeted ("188.63.191.24", 8888)
			create pac.make (10)
			soc.send (pac, 0)
			print ("Packet sent")
		end

end
