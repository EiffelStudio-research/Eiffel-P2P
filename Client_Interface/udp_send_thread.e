
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
				if Utils.send_queue.something_to_send then

					if  Utils.send_queue.readable then
						send
					end
				else
					current.sleep (utils.send_thread_timeout)
				end


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
				send_json := utils.send_queue.item
				print("Picked up a JSON Object to send %N")
				send_string := send_json.representation
				print("This is the send String: " + send_string + "%N")

				create pac.make (send_string.count)
				from i := 1
				until i > send_string.count
				loop
					pac.put_element (send_string.item (i), i-1)
				end
				print("Finished parsing to char" + "%N")

				create t.make_now
				soc.send (pac, 0)

				print("Sent packet " + send_string  + " " + t.out + "%N")
			end
		end

feature {NONE} --data
	utils:UTILS

end
