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
		end

	connect_to_server(server_ip_address: STRING server_port: INTEGER my_local_port: INTEGER): BOOLEAN
		local
			addr: detachable NETWORK_SOCKET_ADDRESS
		do
			create main_tcp_soc.make_client_by_port (server_port, server_ip_address)
			create addr.make_any_local (my_local_port)

			if
				attached main_tcp_soc as soc
			then
				soc.set_address (addr)
				soc.set_reuse_address
				soc.bind
				Result := connect
			end
		end

	connect_to_server_any_port(server_ip_address: STRING server_port: INTEGER): BOOLEAN
		do
			create main_tcp_soc.make_client_by_port (server_port, server_ip_address)
			Result := connect
		end

	cleanup_connection
		do
			if attached main_tcp_soc as soc then
                soc.cleanup
                soc.dispose
            end
		end

	tcp_hole_punch(peer_ip_address: STRING peer_port: INTEGER my_local_port: INTEGER): BOOLEAN

		local
			in_soc: detachable NETWORK_STREAM_SOCKET
			out_soc: detachable NETWORK_STREAM_SOCKET
			addr: detachable NETWORK_SOCKET_ADDRESS



			connector: CONNECT_THREAD
			listenor: LISTEN_THREAD
		do

			create addr.make_any_local (my_local_port)

			print("creating out socket!%N")
			create out_soc.make_client_by_port (peer_port, peer_ip_address)





			out_soc.set_address (addr)
			out_soc.set_reuse_address
			out_soc.bind

			create connector.make_by_socket (out_soc)

			print("creating in socket!%N")
			create in_soc.make
			in_soc.set_address (addr)
			in_soc.set_reuse_address
			in_soc.bind

			create listenor.make_by_socket (in_soc)


			print("launch listener %N")
			listenor.launch

			print("launch connector %N")
			connector.launch




			connector.join_all
			print("Checking for connections %N")
			if(in_soc.is_connected) then
				print("in_soc connected %N")
				main_tcp_soc := in_soc
				out_soc.cleanup
				Result := True
			elseif (out_soc.is_connected) then
				print("out_soc connected %N")
				main_tcp_soc := out_soc
				in_soc.cleanup
				Result := True
			else
				print("No connection established via tcp hole punching %N")
				Result := False
			end



		rescue
			if attached in_soc as soc then
				soc.cleanup
			end
			if attached out_soc as soc then
				soc.cleanup
			end

			Result := False

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


			create sender.make_by_socket (out_soc)


			create receiver.make_by_socket (out_soc)


			print("launching receiver!%N")
			receiver.launch

			print("launching sender!%N")
			sender.launch


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

feature {NONE}

	-- helper function for connect_to_server
	connect: BOOLEAN
		do
			if
				attached main_tcp_soc as soc
			then
				soc.connect
				if soc.is_connected then
					print ("Connection established!%N")
					Result := True
				else
					print ("Connect to server failed!%N")
					cleanup_connection
					Result := False
				end
			else
				print ("Socket creation failed!%N")
				cleanup_connection
				Result := False

			end
		rescue
			print ("Connect to server failed!%N")
			Result := False
            cleanup_connection
		end

end
