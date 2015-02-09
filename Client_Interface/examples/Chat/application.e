note
	description : "chat application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	SHARED_EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			p2p_setup: P2P_SETUP
			args: ARGUMENTS_32
			i,j,n: INTEGER
			v,s: STRING_32
			arg_server, arg_local: detachable READABLE_STRING_32

			l_server_ip: detachable READABLE_STRING_32
			l_server_port: INTEGER
			l_local_port_lower, l_local_port_upper: INTEGER
		do
				-- Use value from environment variables if set.
			arg_server := execution_environment.item ("CHAT_P2P_SERVER")
			arg_local := execution_environment.item ("CHAT_P2P_LOCAL")

				-- Use value from arguments if set.
			args := execution_environment.arguments
			from
				i := 1
				n := args.argument_count
			until
				i > n
			loop
				v := args.argument (i)
				if v.same_string_general ("--server") then
					if i + 1 <= n then
						arg_server := args.argument (i + 1)
						i := i + 1
					end
				elseif v.same_string_general ("--local") then
					if i + 1 <= n then
						arg_local := args.argument (i + 1)
						i := i + 1
					end
				end
				i := i + 1
			end

				-- Default
			l_local_port_lower := 40001
			l_server_port := 8888

				-- From command line or environment
			if arg_server /= Void then
				v := arg_server
				j := v.index_of (':', 1)
				if j > 0 then
					s := v.substring (j + 1, v.count)
					if s.is_integer then
						l_server_port := s.to_integer
					end
					v.keep_head (j - 1)
				end
				l_server_ip := v
			end
			if arg_local /= Void then
				v := arg_local
				j := v.index_of (':', 1)
				if j > 0 then
					s := v.substring (j + 1, v.count)
					if s.is_integer then
						l_local_port_upper := s.to_integer_32
					else
						print ("Invalid error for local%N")
						(create {EXCEPTIONS}).die (-1)
					end
					v.keep_head (j - 1)
				end
				if v.is_integer then
					l_local_port_lower := v.to_integer_32
					l_local_port_upper := l_local_port_upper.max (l_local_port_lower)
				else
					print ("Invalid error for local%N")
					(create {EXCEPTIONS}).die (-1)
					check False end
				end
			end

			if l_server_ip = Void then
				l_server_ip := "127.0.0.1" -- FIXME
			end

			create p2p_setup.make (l_server_ip, l_server_port, l_local_port_lower, l_local_port_upper)

			create chat_client.make (p2p_setup)
			create login.make (chat_client)
			create logout.make (chat_client)
			create main_menu.make (chat_client)
			create chatroom.make (chat_client)
			start
		end
feature {NONE} -- Logic

	start
		do
			chat_client.start
			from
				chat_client.currentstate := 3
			until
				chat_client.currentstate = -1
			loop
				inspect
					chat_client.currentstate
				when 0 then
					print("**** LOGOUT ****%N")
					logout.show
				when 1 then
					print("****MAIN MENUE****")
					main_menu.show
				when 2 then
					print ("****CHATROOM****")
					chatroom.show
				when 3 then
					print ("**** LOGIN ****%N")
					login.show
				else

				end
			end
			chat_client.exit
		end

feature {NONE} --Fields

	chat_client: CHAT_CLIENT

	login: CHAT_LOGIN_COMMAND
	logout: CHAT_LOGOUT_COMMAND
	main_menu: CHAT_MAIN_MENU
	chatroom: CHATROOM

end
