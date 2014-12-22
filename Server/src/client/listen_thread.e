note
	description: "Summary description for {LISTEN_THREAD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LISTEN_THREAD

inherit
	THREAD

create
	make_by_socket

feature

	socket: detachable NETWORK_STREAM_SOCKET

	make_by_socket(ref_socket: detachable NETWORK_STREAM_SOCKET)
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
		do
			if attached socket as soc then
				soc.listen (20)
			end
		end

end
