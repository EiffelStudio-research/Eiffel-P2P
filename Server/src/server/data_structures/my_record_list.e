note
	description: "Summary description for {MY_RECORD_LIST}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MY_RECORD_LIST

create
	make

feature
	make
		do
			create my_record_list.make
		end
	find_record(record_id: NATURAL_64): MY_RECORD
		local
			found: BOOLEAN
		do
			from
				found := false
				my_record_list.start
				create RESULT.make_invalid
			until
				found or my_record_list.after
			loop
				if
					my_record_list.item.get_id = record_id
				then
					RESULT := my_record_list.item
					found := true
				end
				my_record_list.forth
			end
		end
feature {MESSAGE_PROCESS_MODULE}
	add_record(record: MY_RECORD): BOOLEAN
		local
			existed_record: MY_RECORD
		do
			existed_record := find_record(record.get_id)
			if
				existed_record.is_valid
			then
				RESULT := false
			else
				my_record_list.force (record)
				RESULT := true
			end
		end
	edit_record(updated_record: MY_RECORD): BOOLEAN
		local
			record_id: NATURAL_64
			record_key: NATURAL_64
			found: BOOLEAN
			updated_ipv4_addr: NATURAL_32
			updated_port: NATURAL_32
		do
			record_id := updated_record.get_id
			record_key := updated_record.get_key
			updated_ipv4_addr := updated_record.record_ipv4_addr
			updated_port := updated_record.record_port
			from
				found := false
				my_record_list.start
				RESULT := false
			until
				RESULT or my_record_list.after
			loop
				if
					my_record_list.item.get_id = record_id and then my_record_list.item.validate_key (record_key)
				then
					my_record_list.item.set_ipv4_addr(updated_ipv4_addr)
					my_record_list.item.set_port(updated_port)
					RESULT := true
				end
				my_record_list.forth
			end
		end
feature {NONE}
	my_record_list: LINKED_LIST[MY_RECORD]
end
