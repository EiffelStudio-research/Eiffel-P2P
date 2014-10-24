note
	description: "Summary description for {BODY_PARSER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BODY_PARSER
create
	make_from_packet

feature {ANY}
	make_from_packet(pkt: MY_PACKET)
		do
			create current_body.make_from_array(pkt)
			current_body.rebase (0)
			current_body := current_body.subarray (20, current_body.count - 1)
			current_body.rebase (0)
		end

	get_attributes: ARRAY[MY_ATTRIBUTE]
		local
			current_type: NATURAL_16
			current_length: INTEGER
			current_value: ARRAY[NATURAL_8]
			current_attribute: MY_ATTRIBUTE
			count: INTEGER
			i: INTEGER

		do
			create RESULT.make_empty
			from
				count := 0
				i := 0
			until
				count = current_body.count
			loop
				current_type := current_body.at (count).as_natural_16 * 256 + current_body.at (count + 1).as_natural_16
				current_length := current_body.at (count + 2).as_integer_32 * 256 + current_body.at (count + 3).as_integer_32
				current_value := current_body.subarray (count + 4, count + 3 + current_length)
				current_value.rebase (0)
				create current_attribute.make (current_type, current_value)
				RESULT.put (current_attribute, i)
				i := i + 1
				count := count + 4
				if
					current_length - (current_length // 4) * 4 = 0
				then
					count := count + current_length
				else
					count := count + (current_length // 4 + 1) * 4
				end

			end
		end
feature {NONE}
	current_body: ARRAY[NATURAL_8]
end
