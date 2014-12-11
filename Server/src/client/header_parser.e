note
	description: "This class is responsible for parsing the header of the packets received add pass it to the correct protocol handler"
	author: "Qing Cheng"
	date: "11/4/2014"
	revision: "$Revision$"

class
	HEADER_PARSER

create
	make_from_packet

feature {ANY}
	make_from_packet(pkt: MY_PACKET)
		do
			create current_packet.make_from_array(pkt)
			current_packet.rebase (0)
		end

	demultiplex: INTEGER
		local
			first_byte: NATURAL_8
			first_two_bits: NATURAL_8
		do
			first_byte := current_packet.at (0)
			first_two_bits := first_byte.bit_and (0b11000000)
			if
				first_two_bits = 0b11000000
			then
				RESULT := 1
				print("This is an EP packet %N");
			else
				RESULT := 0
				print("This is a STUN packet %N");
			end
		end

	get_class: INTEGER
		local
			first_two_bytes: ARRAY[NATURAL_8]
			first_bit: NATURAL_8
			second_bit: NATURAL_8
		do
			create first_two_bytes.make_from_array (current_packet.subarray (0, 1))
			first_two_bytes.rebase (0)
			first_bit := first_two_bytes.at (0).bit_and (0b00000001)
			first_bit := first_bit.bit_shift_left (1)
			second_bit := first_two_bytes.at (1).bit_and (0b00010000)
			second_bit := second_bit.bit_shift_right (4)
			RESULT := first_bit.bit_or (second_bit)
		end

	get_method: INTEGER
		local
			first_two_bytes: ARRAY[NATURAL_8]
			first_bit: NATURAL_8
			second_bit: NATURAL_8
			method: NATURAL_16
		do
			create first_two_bytes.make_from_array (current_packet.subarray (0, 1))
			first_two_bytes.rebase (0)
			method := 0;
			first_bit := first_two_bytes.at (0).bit_and (0b00111110)
			method := method.bit_or (first_bit.as_natural_16)
			method := method.bit_shift_left (6)
			second_bit := first_two_bytes.at (1).bit_and (0b11101111)
			second_bit := second_bit.bit_shift_right (5).bit_shift_left (4).bit_or (second_bit.bit_shift_left (4).bit_shift_right (4))
			method := method.bit_or (second_bit.as_natural_16)
			RESULT := method
		end

	get_length: INTEGER
		local
			bytes: ARRAY[NATURAL_8]
		do
			create bytes.make_from_array (current_packet.subarray (2, 3))
			bytes.rebase (0)
			RESULT := bytes.at (0) * 256 + bytes.at (1)
		end

	get_magic_cookie: ARRAY[NATURAL_8]
		local
			bytes: ARRAY[NATURAL_8]
		do
			create bytes.make_from_array (current_packet.subarray (4, 7))
			bytes.rebase (0)
			RESULT := bytes
		end

	get_transaction_id: ARRAY[NATURAL_8]
--		local
--			bytes: ARRAY[NATURAL_8]
--			current_nat: NATURAL_32
--			i: INTEGER
		do
--			create bytes.make_from_array (current_packet.subarray (8, 19))
--			bytes.rebase (0)
--			create RESULT.make_empty
--			from
--				i := 0
--			until
--				i = 3
--			loop
--				current_nat := bytes[i * 4].as_natural_32 * 256 * 256 * 256 + bytes[i * 4 + 1].as_natural_32 * 256 * 256 + bytes[i * 4 + 2].as_natural_32 * 256 + bytes[i * 4 + 3].as_natural_32;
--				RESULT.append (current_nat.to_hex_string)
--				i := i + 1
--			end
			create RESULT.make_from_array (current_packet.subarray (8, 19))
			RESULT.rebase (0)
		end

feature {NONE}
	current_packet: MY_PACKET

	to_unsigned(header: ARRAY[INTEGER_8]): ARRAY[NATURAL_8]
		local
			size: INTEGER
			result_array: ARRAY[NATURAL_8]
			i: INTEGER
		do
			size := header.count
			create result_array.make_filled (0, 1, size + 1)
			from
				i := 1
			until
				i = size + 1
			loop
				result_array.put (header.at(i).as_natural_8, i)
				i := i + 1
			end
			RESULT := result_array
		end
end
