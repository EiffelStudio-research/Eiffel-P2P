note
	description: "Summary description for {UDP_RECEIVE_THREAD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	UDP_RECEIVE_THREAD

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
			listen
		end

	listen
		require
			socket_not_void: socket /= Void

		local
			pac: PACKET
			i: INTEGER
		do
			if attached socket as soc then
				soc.set_timeout (10)
				from
					i:= 1
				until
					i = 5
				loop
					pac := soc.received (24, 0)
					print("Received: " + pac.at (1).out + "%N")

					i := i + 1
				end
			end
		end

end
