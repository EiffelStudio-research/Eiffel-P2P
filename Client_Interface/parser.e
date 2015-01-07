note
	description: "Summary description for {PARSER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PARSER_THREAD
inherit
	THREAD

create
	make_parse

feature

	make_parse(a_utils:UTILS)
		do
			utils:=a_utils
		end

feature --Execute

	execute
		do
		end

feature {NONE} --data
	utils:UTILS
end
