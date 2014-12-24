note
	description: "Summary description for {UDP_SEND_THREAD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	UDP_SEND_THREAD

inherit
	THREAD


create
	make_by_socket

feature

	socket: detachable NETWORK_DATAGRAM_SOCKET

	make_by_socket(ref_socket: detachable NETWORK_DATAGRAM_SOCKET)
		do
			make
			socket := ref_socket
		end



	execute
		do
			send
		end

	send
		require
			socket_not_void: socket /= Void

		local
			pac: DATAGRAM_PACKET
			i: INTEGER
		do
			create pac.make (8)

			if attached socket as soc then
				from
					i:= 1
				until
					i = 5
				loop
					create pac.make (8)
					pac.put_element (i.to_character_8, 1)
					soc.send (pac, 0)

					current.sleep (1000000000)

					i := i + 1

				end

			end





		end

end
