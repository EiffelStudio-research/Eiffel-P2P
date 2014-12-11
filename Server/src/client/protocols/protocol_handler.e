note
	description: "Summary description for {PROTOCOL_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PROTOCOL_HANDLER
feature
	generate_feedback: FEEDBACK
		deferred
		end
	is_known: BOOLEAN
		deferred
		end
	validate_message: BOOLEAN
		deferred
		end

	generate_error_reason(reason_data: ARRAY[NATURAL_8]): STRING
		require
			valid_data_length: reason_data.count = 4
		local
			reason_code: NATURAL_32
		do
			reason_code := generate_reason_code(reason_data)
			inspect
				reason_code
			when
				0
			then
				RESULT := "Unknown method in request packet."
			when
				1
			then
				RESULT := "Invalid attributes in request packet."
			when
				2
			then
				RESULT := "ID conflict, please retry 'register' command."
			when
				3
			then
				RESULT := "Requested ID has not been registered yet. Please confirm your peer's ID first and try again."
			when
				4
			then
				RESULT := "Your ID and KEY do not match."
			else
				RESULT := "Unknown reason."
			end
		end
feature{NONE}
	generate_reason_code(reason_data: ARRAY[NATURAL_8]): NATURAL_32
		require
			valid_data_length: reason_data.count = 4
		local
			i: INTEGER
		do
			from
				i := 0
				RESULT := 0
			until
				i = 4
			loop
				RESULT := RESULT.bit_or (reason_data.at (i).as_natural_32.bit_shift_left ((3 - i) * 8))
				i := i + 1
			end
		end
end
