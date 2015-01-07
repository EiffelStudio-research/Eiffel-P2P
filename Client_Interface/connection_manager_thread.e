note
	description: "Summary description for {CONNECTION_MANAGER_THREAD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CONNECTION_MANAGER_THREAD
inherit
	THREAD
create
	make_new

feature
	make_new (a_peer_ip_address: STRING a_peer_port: INTEGER a_my_local_port: INTEGER; a_utils: UTILS)
		do
			make
			peer_ip_address := a_peer_ip_address
			peer_port := a_peer_port
			my_local_port := a_my_local_port
			utils := a_utils
		end

	execute
		do
			udp_hole_punch (peer_ip_address, peer_port, my_local_port)
		end

feature {NONE}--Internal
	peer_ip_address: STRING
	peer_port: INTEGER
	my_local_port: INTEGER
	utils:UTILS

	udp_hole_punch(a_peer_ip_address: STRING a_peer_port: INTEGER a_my_local_port: INTEGER)
		local
			sender: UDP_SEND_THREAD
			receiver: UDP_RECEIVE_THREAD
			in_soc: detachable NETWORK_DATAGRAM_SOCKET
			out_soc: detachable NETWORK_DATAGRAM_SOCKET
			addr: detachable NETWORK_SOCKET_ADDRESS
			timed_out: BOOLEAN
		do

			create addr.make_from_hostname_and_port (a_peer_ip_address, a_peer_port)

			print("creating out socket!%N")
			create out_soc.make_bound (a_my_local_port)
			out_soc.set_peer_address (addr)
			out_soc.set_reuse_address

			utils.set_send_thread_running(true)
			utils.set_receive_thread_running (true)

			create sender.make_by_socket (out_soc,utils)


			create receiver.make_by_socket (out_soc,utils)


			print("launching receiver!%N")
			receiver.launch

			print("launching sender!%N")
			sender.launch


			--sender.exit

			sender.join
			receiver.join

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

end
