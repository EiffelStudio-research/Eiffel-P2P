note
	description: "Summary description for {MY_RECORD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MY_RECORD
create
	make_from_id, make_invalid, make
feature {ANY}
	make_from_id(id: NATURAL_64)
		local
			random_generator: RANDOM
		do
			create random_generator.make
			record_id := id
			random_generator.start
			record_key := random_generator.item.as_natural_64.bit_shift_left (32).bit_or (random_generator.item.as_natural_64)
			record_ipv4_addr := 0
			record_port := 0
			is_valid := true
		end
	make_invalid
		do
			is_valid := false
		end
	make(id: NATURAL_64 key: NATURAL_64 addr: NATURAL_32 port: NATURAL_32)
		do
			record_id := id
			record_key := key
			record_ipv4_addr := addr
			record_port := port
			is_valid := true
		end
	get_id: NATURAL_64
		do
			RESULT := record_id
		end
	get_key: NATURAL_64
		do
			RESULT := record_key
		end
	validate_key(key: NATURAL_64): BOOLEAN
		do
			RESULT := key = record_key
		end
	record_ipv4_addr: NATURAL_32 assign set_ipv4_addr
	record_port: NATURAL_32 assign set_port
	set_ipv4_addr(ipv4_addr: NATURAL_32)
		do
			record_ipv4_addr := ipv4_addr
		end
	set_port(port: NATURAL_32)
		do
			record_port := port
		end
	is_valid: BOOLEAN
feature {NONE}
	record_id: NATURAL_64
	record_key: NATURAL_64
end
