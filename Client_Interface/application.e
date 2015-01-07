note
	description : "client_interface application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			con:CONNECTION_MANAGER
		do
			--| Add your code here
			create con.make
			con.udp_hole_punch ("127.0.0.1", 3400, 3400)
			print ("Hello Eiffel World!%N")
		end

end
