note
	description : "rendezvous_server application root class"
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
		do
			--| Add your code here
			test_send
		end

	test_send
		local
			soc: NETWORK_DATAGRAM_SOCKET
			pac: detachable PACKET

		do
			print ("Hello Eiffel World!%N")
			create soc.make_bound (8888)

			soc.set_timeout (30)


			pac := soc.received (20, 10)

			if attached {MESSAGE} pac as message then

					print(message.message)

			end

			if(attached soc.peer_address as addr) then
				print(addr.host_address.host_address + "/" + addr.port.out + "%N")
			end

			print ("Finished %N")
		end

end
