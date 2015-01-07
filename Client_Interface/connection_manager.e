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
<<<<<<< HEAD

			create addr.make_from_hostname_and_port (peer_ip_address, peer_port)

			print("creating out socket!%N")
			create out_soc.make_bound (my_local_port)
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


			timed_out := sender.join_with_timeout (utils.send_thread_timeout.as_natural_64)
			timed_out := receiver.join_with_timeout (utils.receive_thread_timeout.as_natural_64)

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
=======
			--Wait 10 Seconds
			test := connector.join_with_timeout (10000)
>>>>>>> 95fdc646af8514bc0ef0753461a4907110a14450
		end

feature --data

	utils:UTILS

feature {NONE} -- THread
	connector : CONNECTION_MANAGER_THREAD


end
