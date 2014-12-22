note
	description: "Summary description for {CONNECT_THREAD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CONNECT_THREAD

inherit
	THREAD

create
	make_by_address, make_by_socket

feature

	socket: detachable NETWORK_STREAM_SOCKET

	make_by_socket(ref_socket: detachable NETWORK_STREAM_SOCKET)
		do
			make
			socket := ref_socket
		end

	make_by_address(server_ip: STRING server_port: INTEGER my_port: INTEGER)
		local
			my_address: NETWORK_SOCKET_ADDRESS
		do
			make
			create my_address.make_any_local (my_port)
			create socket.make_client_by_port (server_port, server_ip)
			if attached socket as soc then
				soc.set_address (my_address)
			--	soc.set_reuse_address
				soc.bind
			end
		end

	execute
		do
			connect_to_server
		end

	connect_to_server
		require
			socket_not_void: socket /= Void
		do
			if attached socket as soc then
				soc.connect
			end
		end

end
