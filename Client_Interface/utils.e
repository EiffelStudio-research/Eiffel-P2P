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
	end

feature -- Thread QUeues

	send_queue:MUTEX_LINKED_QUEUE[JSON_OBJECT]
	receive_queue:MUTEX_LINKED_QUEUE[JSON_OBJECT]
end
