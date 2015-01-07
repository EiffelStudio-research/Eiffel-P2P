note
	description: "Summary description for {MUTEX_LINKED_QUEUE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MUTEX_LINKED_QUEUE [G]


inherit
	LINKED_QUEUE
redefine put, extend, force, make, item

feature -- create
	make
	do
		mutex.make
		Precursor
	end

feature -- ACCESS
	put, extend, force (v: G)
	do
		mutex.lock
		Precursor
		mutex.unlock
	end

	item: G
	do
		mutex.lock
		Precursor
		mutex.unlock
	end



feature {NONE} -- Mutex
	mutex:MUTEX

end
