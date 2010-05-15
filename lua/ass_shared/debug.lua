
function ASS.Debug(function_name, message)

	if (CLIENT) then
		print("*CL_DEBUG*", function_name, message)
	end

	if (SERVER) then
		print("*SV_DEBUG*", function_name, message)
	end

end