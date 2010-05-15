
ASS.Resource = {}

if (CLIENT) then

	ASS.Resource.Images = {}
	function ASS.Resource.LoadImage( fn )

		local lFN = string.lower(fn)

		if (!ASS.Resource.Images[lFN]) then

			ASS.Resource.Images[lFN] = surface.GetTextureID(fn)

		end

		return ASS.Resource.Images[lFN]

	end

end

if (SERVER) then

	function ASS.Resource.SendMaterialDir(root)
	
		local all = file.Find(root .. "/*")
		
		for _,entry in pairs(all) do
		
			if (entry != "." && entry != ".." && !file.IsDir(root .. "/" .. entry)) then
			
				local ext = string.sub( string.lower(entry), -4 )
				
				if (ext == ".vmt" || ext == ".vtf") then
				
					resource.AddFile(root .. "/" .. entry)
				
				end
			
			end
		
		end
	
	end
	
end
