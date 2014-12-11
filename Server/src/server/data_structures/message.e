note
	description: "Summary description for {REQUEST}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MESSAGE

create
	make, make_invalid

feature {ANY}
	make(p: INTEGER m: INTEGER c: INTEGER m_c: ARRAY[NATURAL_8] t: ARRAY[NATURAL_8] cra: ARRAY[MY_ATTRIBUTE] coa: ARRAY[MY_ATTRIBUTE])
		do
			protocol := p
			method := m
			message_class := c
			magic_cookie := m_c
			transaction_id := t
			comprehension_required_attributes := cra
			comprehension_optional_attributes := coa
			is_valid := true
		end
	make_invalid
		do
			protocol := 0
			method := 0
			message_class := 0
			create transaction_id.make_empty
			create comprehension_required_attributes.make_empty
			create comprehension_optional_attributes.make_empty
			is_valid := false
			create magic_cookie.make_empty
		end
	protocol: INTEGER
	method: INTEGER
	message_class: INTEGER
	transaction_id: ARRAY[NATURAL_8]
	comprehension_required_attributes: ARRAY[MY_ATTRIBUTE]
	comprehension_optional_attributes: ARRAY[MY_ATTRIBUTE]
	is_valid: BOOLEAN
	magic_cookie: ARRAY[NATURAL_8]

	generate_packet: MY_PACKET
		local
			packet_length: NATURAL_16
			combined_attributes: ARRAY[MY_ATTRIBUTE]
			count: INTEGER
			current_bits: NATURAL_16
			first_two_bytes: NATURAL_16
			current_pos: INTEGER
		do
			combined_attributes := combine_attributes(current.comprehension_required_attributes, current.comprehension_optional_attributes)
			packet_length := 0
			from
				count := 0
			until
				count = combined_attributes.count
			loop
				packet_length := packet_length + combined_attributes.at (count).occupied_length.as_natural_16 + 4
				count := count + 1
			end


			create RESULT.make_filled (0, 0, packet_length + 19)
			first_two_bytes := 0
			first_two_bytes := first_two_bytes.bit_or (current.protocol.as_natural_16.bit_and (0x0003).bit_shift_left (14))

			current_bits := current.message_class.as_natural_16.bit_and (0x0002).bit_shift_left (7)
			first_two_bytes := first_two_bytes.bit_or (current_bits)

			current_bits := current.message_class.as_natural_16.bit_and (0x0001).bit_shift_left (4)
			first_two_bytes := first_two_bytes.bit_or (current_bits)

			current_bits := current.method.as_natural_16.bit_and (0x000F)
			first_two_bytes := first_two_bytes.bit_or (current_bits)

			current_bits := current.method.as_natural_16.bit_and (0x0070).bit_shift_left (1)
			first_two_bytes := first_two_bytes.bit_or (current_bits)

			current_bits := current.method.as_natural_16.bit_and (0x0F80).bit_shift_left (2)
			first_two_bytes := first_two_bytes.bit_or (current_bits)

			RESULT.put (first_two_bytes.bit_shift_right (8).as_natural_8, 0)
			RESULT.put (first_two_bytes.bit_and (0x00FF).as_natural_8, 1)
			RESULT.put (packet_length.bit_shift_right (8).as_natural_8, 2)
			RESULT.put (packet_length.bit_and (0x00FF).as_natural_8, 3)

			RESULT.fill_with_array (4, current.magic_cookie)
			RESULT.fill_with_array (8, current.transaction_id)

			from
				count := 0
				current_pos := 20
			until
				count = combined_attributes.count
			loop
				RESULT.put (combined_attributes.at (count).attribute_name.bit_shift_right (8).as_natural_8, current_pos)
				RESULT.put (combined_attributes.at (count).attribute_name.bit_and (0x00FF).as_natural_8, current_pos + 1)
				RESULT.put (combined_attributes.at (count).value.count.as_natural_16.bit_shift_right (8).as_natural_8, current_pos + 2)
				RESULT.put (combined_attributes.at (count).value.count.as_natural_16.bit_and (0x00FF).as_natural_8, current_pos + 3)
				current_pos := current_pos + 4

				RESULT.fill_with_array (current_pos,  combined_attributes.at (count).value)
				current_pos := current_pos + combined_attributes.at (count).occupied_length
				count := count + 1
			end
		end

feature {NONE}
	combine_attributes(array_1: ARRAY[MY_ATTRIBUTE] array_2: ARRAY[MY_ATTRIBUTE]): ARRAY[MY_ATTRIBUTE]
		local
			count: INTEGER
			empty_attr: MY_ATTRIBUTE
		do
			if
				array_1.count + array_2.count = 0
			then
				create RESULT.make_empty
			else
				create empty_attr.make_empty
				create RESULT.make_filled (empty_attr, 0, array_1.count + array_2.count - 1)
				from
					count := 0
				until
					count = array_1.count
				loop
					RESULT.put (array_1.at (count), count)
					count := count + 1
				end

				from
					count := 0
				until
					count = array_2.count
				loop
					RESULT.put (array_1.at (count), count + array_1.count)
					count := count + 1
				end
			end


		end
end
