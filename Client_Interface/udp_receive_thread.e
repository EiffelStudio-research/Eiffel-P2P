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


	make_by_socket(ref_socket: detachable NETWORK_DATAGRAM_SOCKET; a_receive_queue: MUTEX_LINKED_QUEUE)

		do
			make
			socket := ref_socket
			receive_queue := a_receive_queue
		end

feature --Execute

	execute
		do
			from
			until not {utils}.receive_thread_running
			loop
				listen
				current.sleep ({utils}.receive_thread_timeout)
			end

		end

	listen
		require
			socket_not_void: socket /= Void

		local
			pac: PACKET
			i: INTEGER
			received_string: STRING
			json_parser:JSON_PARSER
			json_object:detachable JSON_OBJECT
		do
			if attached socket as soc then
				soc.set_timeout (10)
				--HOw to hansle size?
				pac :=  soc.received (1024, 0)
				--soc.read_stream (10)

					--s := soc.laststring
				print("Received Packet ")
				receive_queue.force (pac)

			end
		end
feature {NONE} -- Thread QUeues

	receive_queue:MUTEX_LINKED_QUEUE
end
