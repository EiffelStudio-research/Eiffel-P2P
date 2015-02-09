

note
	description: "[
						This static class provides the constant that are necessary for the p2p protocol to run. Therefore a lot must be 
						equal to the UTILS class of the Client_Interface. For example the error_type constants.
				 ]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	P2P_SERVER_SETUP

create
	make

feature
	make (a_port: INTEGER; a_maximum_packet_size: INTEGER)
		do
			port := a_port
			maximum_packet_size := a_maximum_packet_size
		end

feature -- socket constants

	port : INTEGER

feature -- protocol must be the same as for the client_interface

	maximum_packet_size: INTEGER

feature -- Change	

	set_port (a_port: like port)
		require
			a_port >= 0
		do
			port := a_port
		end

	set_maximum_packet_size (a_maximum_packet_size: like maximum_packet_size)
		require
			a_maximum_packet_size > 0
		do
			maximum_packet_size := a_maximum_packet_size
		end

end
