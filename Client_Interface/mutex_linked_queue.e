note
	description: "Summary description for {MUTEX_LINKED_QUEUE}."
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
		Result:=list.readable
	end

	something_in: BOOLEAN
	do
		RESULT := not list.is_empty
	end



feature {NONE} -- Mutex
	mutex:MUTEX
feature {NONE} -- List
	list:LINKED_QUEUE [G]

end
