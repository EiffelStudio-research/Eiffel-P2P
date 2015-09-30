note
	description: "Summary description for {P2P_RENDEZVOUS_LOGGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	P2P_RENDEZVOUS_LOGGER

feature -- Access

	put_information (m: READABLE_STRING_8)
		do
			io.put_string (m)
			io.put_new_line
		end

	put_debug (m: READABLE_STRING_8)
		do
			io.put_string ("[DEBUG] ")
			io.put_string (m)
			io.put_new_line
		end

	put_error (m: READABLE_STRING_8)
		do
			io.put_string ("[ERROR] ")
			io.put_string (m)
			io.put_new_line
		end

end
