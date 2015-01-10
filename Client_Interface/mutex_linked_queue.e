note
	description: "Summary description for {MUTEX_LINKED_QUEUE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MUTEX_LINKED_QUEUE





create
	make



feature -- create
	make
	do
		create list.make
		create mutex.make
	end

feature -- ACCESS
	put(v: PACKET)
	do
		--mutex.lock
		list.put(v)
		--mutex.unlock
	end

	extend(v: PACKET)
	do
		--mutex.lock
		list.extend(v)
		--mutex.unlock
	end

	force(v: PACKET)
	do
		--mutex.lock
		list.force(v)
		--mutex.unlock
	end

	item: PACKET
	do
		--mutex.lock
			Result:= list.item
			list.remove -- TODO: is that true ?
		--mutex.unlock
	end

	readable:BOOLEAN
	do
		Result:=list.readable
	end

	something_to_send: BOOLEAN
	do
		RESULT := not list.is_empty
	end



feature {NONE} -- Mutex
	mutex:MUTEX
feature {NONE} -- List
	list:LINKED_QUEUE [PACKET]

end
