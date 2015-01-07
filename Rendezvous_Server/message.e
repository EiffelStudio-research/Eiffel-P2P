note
	description: "Summary description for {MESSAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MESSAGE

inherit
	PACKET

create
	make,
	make_from_managed_pointer


feature

	message: detachable STRING

	set_message(a_message: STRING)
	do
		message:= a_message
	end

end
