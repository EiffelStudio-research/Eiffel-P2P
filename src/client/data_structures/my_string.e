note
	description: "Summary description for {MY_STRING}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MY_STRING

inherit
	STORABLE
create
	make_from_string
feature
	make_from_string(s: STRING)
		do
			message := s
		end
	message:STRING

end
