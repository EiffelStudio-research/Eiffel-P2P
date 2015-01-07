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


	make_by_socket(ref_socket: detachable NETWORK_DATAGRAM_SOCKET a_utils:UTILS)

		do
			make
			socket := ref_socket
			utils:=a_utils
		end

feature --Execute

	execute
		do
			from
			until not utils.receive_thread_running
			loop
				listen
				current.sleep (utils.receive_thread_timeout)
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
				print("Received: ")

				--Parse packet to string
				from  i := 1;received_string := ""
				until i > pac.count
				loop
					received_string.append_character (pac.at (i))
				end

				if  pac.count > 0 then
					-- Try to parse the JSON Object
					create json_parser.make_with_string(received_string)
					if json_parser.is_parsed then
						json_object := json_parser.parsed_json_object
						if json_object /= Void then
							utils.receive_queue.extend (json_object)
						else
							print("Not parcable as json object")
						end
					else
						print("Error parsing: not parsed")
					end
				else
					print(" empty packet")
				end
					print("%N")
			end
		end
feature {NONE} --data
	utils:UTILS

end
