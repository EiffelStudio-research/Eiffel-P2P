
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


	make_by_socket(ref_socket: detachable NETWORK_DATAGRAM_SOCKET a_utils:UTILS)

		do
			make
			socket := ref_socket
			utils:=a_utils
		end

feature -- Execute

	execute
		do
			from

			until
				not utils.send_thread_running
			loop
				send
				current.sleep (utils.send_thread_timeout)
			end
		end

	send
		require
			socket_not_void: socket /= Void

		local
			pac: PACKET
			i: INTEGER
			t: TIME
			send_string : STRING
			send_json:JSON_OBJECT
		do
			if attached socket as soc then
				create t.make_now
				send_json := utils.receive_queue.item
				print("Picked up a JSON Object to send")
				send_string := send_json.representation
				print("This is the sens String: " + send_string)

				create pac.make (send_string.count)
				from i := 1
				until i > send_string.count
				loop

					create t.make_now
					create pac.make (8)



					pac.put_element (i.to_character_8, 1)

					soc.send (pac, 0)
				--	soc.independent_store (pac)


					pac.put_element (send_string.item (i), i)
				end
				print("Finished parsing to char")


				soc.send (pac, 0)
			--	soc.independent_store (pac)

				print("Sent packet " + send_string  + " " + t.out + "%N")

			end
		end

feature {NONE} --data
	utils:UTILS

end
