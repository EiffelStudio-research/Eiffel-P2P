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
			Result := 200000
		end
	receive_thread_timeout:INTEGER
		do
			Result := 200000
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

end
