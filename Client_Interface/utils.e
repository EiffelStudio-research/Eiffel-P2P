note
	description: "This classs gives the basic values"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	UTILS

create
	make

feature -- Male
	make
	do
		create send_queue.make
		create receive_queue.make
		send_thread_running := false
		receive_thread_running := false
	end

feature -- Thread QUeues

	send_queue:MUTEX_LINKED_QUEUE
	receive_queue:MUTEX_LINKED_QUEUE

feature --Timeouts
	send_thread_timeout:INTEGER
		do
			Result := 2000
		end
	receive_thread_timeout:INTEGER
		do
			Result := 2000
		end

feature -- Thread Control
	send_thread_running:BOOLEAN
	receive_thread_running:BOOLEAN

	set_send_thread_running(v : BOOLEAN)
	do
		send_thread_running := v
	end

	set_receive_thread_running(v:BOOLEAN)
	do
		receive_thread_running := v
	end

feature -- protocol

	register_name_key: STRING = "name"

	name_to_query_key: STRING = "name"
	queried_ip_key: STRING = "peer_ip_address"
	queried_port_key: STRING = "peer_ip_port"

	message_type_key: STRING = "type"





	register_message: INTEGER = 1

	query_message: INTEGER = 2

	unregister_message: INTEGER = 3

	keep_alive_message: INTEGER = 4

end
