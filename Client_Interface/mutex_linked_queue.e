note
	description: "Summary description for {MUTEX_LINKED_QUEUE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MUTEX_LINKED_QUEUE


<<<<<<< HEAD
inherit
	LINKED_QUEUE [G]
redefine put, extend, force, make, item
=======

create
	make
>>>>>>> cbb57d5a609bdf23713f8d9da61fe49971c26f3d


feature -- create
	make
	do
		create list.make
		create mutex.make
	end

feature -- ACCESS
	put(v: JSON_OBJECT)
	do
		mutex.lock
		list.put(v)
		mutex.unlock
	end

	extend(v: JSON_OBJECT)
	do
		mutex.lock
		list.extend(v)
		mutex.unlock
	end

	force(v: JSON_OBJECT)
	do
		mutex.lock
		list.force(v)
		mutex.unlock
	end

	item: JSON_OBJECT
	do
		mutex.lock
		Result:=item
		mutex.unlock
	end



feature {NONE} -- Mutex
	mutex:MUTEX
feature {NONE} -- List
	list:LINKED_QUEUE [JSON_OBJECT]

end
