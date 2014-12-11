note
	description: "Summary description for {MY_ATTRIBUTE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MY_ATTRIBUTE

create
	make, make_empty
feature {ANY}
	make(a: NATURAL_16 v: ARRAY[NATURAL_8])
		do
			attribute_name := a
			value := v
			if
				v.count \\ 4 = 0
			then
				occupied_length := v.count
			else
				occupied_length := (v.count // 4 + 1) * 4
			end
		end
	attribute_name: NATURAL_16
	occupied_length: INTEGER
	value: ARRAY[NATURAL_8]
	make_empty
		do
			attribute_name := 0
			create value.make_empty
		end
feature {ANY}
--	get_name_length(packet: ARRAY[NATURAL_8])
--		do
--			packet.rebase (0)
--			attribute_name := packet.at (0).as_natural_16.bit_shift_left (8).bit_or (packet.at (1).as_natural_16)
--			occupied_length := packet.at (2).as_natural_16.bit_shift_left (8).bit_or (packet.at (3).as_natural_16)
--		end

	generate_packet: ARRAY[NATURAL_8]
		local
			count: INTEGER
		do
			create RESULT.make_filled (0, 0, 3 + occupied_length)
			RESULT.at (0) := attribute_name.bit_shift_right (8).as_natural_8
			RESULT.at (1) := attribute_name.bit_and (0x00FF).as_natural_8
			RESULT.at (2) := occupied_length.bit_shift_right (8).as_natural_8
			RESULT.at (3) := occupied_length.bit_and (0x00FF).as_natural_8
			from
				count := 0
			until
				count = value.count
			loop
				RESULT.at (count + 4) := value.at (count)
				count := count + 1
			end
		end
end
