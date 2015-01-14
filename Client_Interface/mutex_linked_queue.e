note
	description: "[
					When sending a packet CONNECTION_MANAGER puts it in a MUTEX_LINKED_QUEUE called send_queue. On the other side UDP_RECEIVE_THREAD
					periodically checks whether there is something in the queue and if so sends the packet. 
					When receiving a packet in UDP_RECEIVE_THREAD and if the packet is for the user it is pushed into a MUTEX_LINKED_QUEUE 
					from where a client can read it in CONNECTION_MANAGER receive. 
					This architecture allows to separate the client application (main thread) from receiving and sending. As multiple Threads
					access the queues the access is only given while holding a lock on a MUTEX.

				]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MUTEX_LINKED_QUEUE [G]





create
	make



feature -- create
	make
	do
		create list.make
		create mutex.make
	end

feature -- ACCESS
	put(v: G)
	do
		mutex.lock
		list.put(v)
		mutex.unlock
	end

	extend(v: G)
	do
		mutex.lock
		list.extend(v)
		mutex.unlock
	end

	force(v: G)
	do
		mutex.lock
		list.force(v)
		mutex.unlock
	end

	item: G
	do
		mutex.lock
			Result:= list.item
			list.remove
		mutex.unlock
	end

	readable:BOOLEAN
	do
		mutex.lock
		Result:=list.readable
		mutex.unlock
	end

	something_in: BOOLEAN
	do
		mutex.lock
		RESULT := not list.is_empty
		mutex.unlock
	end



feature {NONE} -- Mutex
	mutex:MUTEX
feature {NONE} -- List
	list:LINKED_QUEUE [G]

end
