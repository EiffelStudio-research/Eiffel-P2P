note
	description : "When set as root class TEST was and can be used to test the Client_Interface. It is not necessary for the Client_Interface to run."
	date        : "$Date$"
	revision    : "$Revision$"

class
	TEST

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make
		do
			create manager.make

			manager.start

			test_register("Silvan")

			test_registered_users

			test_register("Bob")

			test_registered_users

			test_unregister("Silvan")

			test_registered_users

			test_unregister("Bob")

			test_registered_users

			manager.stop


		end

	test_register(name: STRING)
		do
			if  manager.register(name) then

			else
				print("error: " + manager.register_error_type.out + "%N")
			end
		end

	test_unregister(name: STRING)
		do
			if  manager.unregister(name) then

			else
				print("error: " + manager.unregister_error_type.out + "%N")
			end
		end

	test_query(name: STRING)
		do
			if  manager.query(name) then
				print(manager.peer_address.host_address.host_address + ":" + manager.peer_address.port.out + "%N")
			else
				print("error: " + manager.query_error_type.out + "%N")
			end
		end

	test_registered_users
		do
			if manager.get_registered_users then
				across manager.registered_users as user
				loop
					print(user.item + ", ")
				end
				print("%N")
			else
				print("error: " + manager.registered_users_error_type.out + "%N")
			end
		end

feature
	manager: CONNECTION_MANAGER


end
