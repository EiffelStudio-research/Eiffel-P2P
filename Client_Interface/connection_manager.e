note
	description: "Summary description for {CONNECTION_MANAGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CONNECTION_MANAGER

create
	make

feature

	main_tcp_soc: detachable NETWORK_STREAM_SOCKET

feature

	make
		do
			create utils.make
		end




	udp_hole_punch(peer_ip_address: STRING peer_port: INTEGER my_local_port: INTEGER)
		local
			in_soc: detachable NETWORK_DATAGRAM_SOCKET
			out_soc: detachable NETWORK_DATAGRAM_SOCKET
			addr: detachable NETWORK_SOCKET_ADDRESS



			timed_out: BOOLEAN
			sender: UDP_SEND_THREAD
			receiver: UDP_RECEIVE_THREAD
		do

			create addr.make_from_hostname_and_port (peer_ip_address, peer_port)

			print("creating out socket!%N")
			create out_soc.make_bound (my_local_port)
			out_soc.set_peer_address (addr)
			out_soc.set_reuse_address


			create sender.make_by_socket (out_soc,utils)


			create receiver.make_by_socket (out_soc,utils)


			print("launching receiver!%N")
			receiver.launch

			print("launching sender!%N")
			sender.launch


			sender.exit

			timed_out := sender.join_with_timeout (20000)
			timed_out := receiver.join_with_timeout (20000)

			if attached in_soc as soc then
				soc.cleanup
			end
			if attached out_soc as soc then
				soc.cleanup
			end

		rescue
			if attached in_soc as soc then
				soc.cleanup
			end
			if attached out_soc as soc then
				soc.cleanup
			end
		end
feature --data

	utils:UTILS

end
