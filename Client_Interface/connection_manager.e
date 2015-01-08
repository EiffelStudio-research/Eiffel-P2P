note
	description: "Summary description for {CONNECTION_MANAGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CONNECTION_MANAGER

create
	make

feature -- Extern

	make(a_peer_ip_address: STRING_8; a_peer_port, a_my_local_port: INTEGER_32)
		do
			create utils.make
			print("Created UTILS %N")
			create connector.make_new (a_peer_ip_address, a_peer_port, a_my_local_port, utils)
			print("New Connector: %N")
			print("PEER_IP_ADDRESS: " + a_peer_ip_address + "%N")
			print("PEER_PORT: " + a_peer_port.out + "%N")
			print("LOCAL_PORT: " + a_my_local_port.out + "%N")
		end


		send(a_object: JSON_OBJECT)
		do
			Utils.send_queue.extend (a_object)
			print("Added JSON Object to Sender Queue: " + a_object.representation + "%N")
		end

		start
		do
			connector.launch
		end

		close
		local
			test: BOOLEAN
		do

			--Wait 10 Seconds
			test := connector.join_with_timeout (10000)

		end

feature --data

	utils:UTILS

feature {NONE} -- THread
	connector : CONNECTION_MANAGER_THREAD

	udp_receiver: UDP_RECEIVE_THREAD
	udp_sender: UDP_SEND_THREAD
end
