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
			i, j: INTEGER
			--s: STRING
		do
			if attached socket as soc then
				soc.set_timeout (10)
				from
					i:= 1
				until
					i = 5
				loop
					pac := soc.received (24, 0)
					--soc.read_stream (10)

					--s := soc.laststring
					print("Received: ")

					from
						j := 1
					until
						j = pac.count
					loop
						print(j.out + ": " + pac.at (j).out + "%T")
						j := j + 1
					end
					print("%N")

					i := i + 1
				end
			end
		end

end
