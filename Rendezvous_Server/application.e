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
			create utils.make
			create socket.make_bound (utils.server_port)

			listen
			test_send
		end


feature -- networking
	listen
		local
			pac: PACKET
			i: INTEGER
			received_string: STRING
			json_parser:JSON_PARSER
			json_object:detachable JSON_OBJECT

		do
			from
			until
				False
			loop
				pac :=  socket.received (1024, 0)
				print("Received: ")

				--Parse packet to string
				from  i := 1;received_string := ""
				until i > pac.count
				loop
					received_string.append_character (pac.element(i-1))
					i := i + 1
				end

				if  pac.count > 0 then
					-- Try to parse the JSON Object
					create json_parser.make_with_string(received_string)
					json_parser.parse_content
					if json_parser.is_parsed then
						json_object := json_parser.parsed_json_object
						if json_object /= Void then
							process(json_object) -- TODO: nicer if processing would be done in a worker_thread
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


	test_send
		local
			soc: NETWORK_DATAGRAM_SOCKET
			pac: detachable PACKET

		do
			print ("Hello Eiffel World!%N")
			create soc.make_bound (8888)

			soc.set_timeout (30)


			pac := soc.received (20, 10)


			if(attached soc.peer_address as addr) then
				print(addr.host_address.host_address + "/" + addr.port.out + "%N")
			end

			print ("Finished %N")
		end

feature -- message handling

 	process(json_object: JSON_OBJECT)
 		local
 			key: JSON_STRING
 			value: detachable JSON_VALUE
 		do
 			create key.make_from_string ("type")

 			value := json_object.item (key)
 			if value /= Void then
 			 	print("Received JSON value: " + value.representation)
 			end

 		end


feature {NONE} --data
	utils: UTILS
	socket: NETWORK_DATAGRAM_SOCKET

end
