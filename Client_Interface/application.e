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
			json:JSON_OBJECT
			jsons:JSON_STRING
			i:INTEGER
		do
			--| Add your code here
			create con.make ("192.168.0.1", 5000, 5500)
			con.start
			create json.make
			create jsons.make_from_string_32 ("User")
			json.put_string ("SImon Peyer",jsons)
			from
				i := 0
			until
				i>1000
			loop
				con.send (json)
				i := i+1
			end
			con.close
		end

end
