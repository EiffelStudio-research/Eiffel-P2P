note
	description: "Summary description for {COMMAND_PARSER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	COMMAND_PARSER
create
	make_from_command
feature {ANY}
	make_from_command(command: STRING)
		local
			command_break_down: LIST[STRING]
			i: INTEGER
		do
			command_break_down := command.split (' ')
			if
				command_break_down.count > 1
			then
				create params.make_filled ("default", 0, command_break_down.count - 1)
				from
					command_break_down.start
					i := 0
				until
					command_break_down.after
				loop
					params.put (command_break_down.item, i)
					command_break_down.forth
					i := i + 1
				end
				method := params.at (0)
				if
					params.count >= 2
				then
					params := params.subarray (1, params.count - 1)
					params.rebase (0)
				else
					create params.make_empty
				end

			elseif
				command_break_down.count = 1
			then

				method := command_break_down.at (1)
				create params.make_empty
			else
				method := "empty command"
				create params.make_empty
			end
		end

	method: STRING
	params: ARRAY[STRING]
end
