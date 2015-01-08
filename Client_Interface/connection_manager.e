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

	make
		do
			create utils.make
			print("Created UTILS %N")
--			create connector.make_new (a_peer_ip_address, a_peer_port, a_my_local_port, utils)
--			print("New Connector: %N")


--			print("PEER_IP_ADDRESS: " + a_peer_ip_address + "%N")
--			print("PEER_PORT: " + a_peer_port.out + "%N")
--			print("LOCAL_PORT: " + a_my_local_port.out + "%N")

			create socket.make_bound (utils.local_port)

			--create udp_receiver.make_by_socket (ref_socket: NETWORK_DATAGRAM_SOCKET, a_utils: UTILS)
		end

	register(a_name: STRING)
		local
			t_pac: TARGET_PACKET
		do
			create t_pac.make_register_packet (a_name)
			utils.send_queue.extend (t_pac)
		end


--		send(a_object: JSON_OBJECT)
--		do
--			Utils.send_queue.extend (a_object)
--			print("Added JSON Object to Sender Queue: " + a_object.representation + "%N")
--		end

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

feature {NONE} -- intern



feature --data

	utils:UTILS

feature {NONE} -- THread
	connector : CONNECTION_MANAGER_THREAD

	socket: NETWORK_DATAGRAM_SOCKET

	udp_receiver: UDP_RECEIVE_THREAD
	udp_sender: UDP_SEND_THREAD
end
