---@class AceDBOptions-3.0
local AceDBOptions = LibStub:NewLibrary("AceDBOptions-3.0", 32)

if not AceDBOptions then return end

function AceDBOptions:GetOptionsTable(db)
	assert(db, "AceDBOptions:GetOptionsTable - db required")

	return {
		type = "group",
		name = "Profiles",
		order = 100,
		args = {
			profiles = {
				name = "Character Profiles",
				type = "group",
				inline = true,
				args = {
					new = {
						name = "New Profile",
						type = "input",
						order = 1,
						get = function() return "" end,
						set = function(info, val)
							if val and val ~= "" then
								db:SetProfile(val)
							end
						end,
					},
					current = {
						name = "Current Profile",
						type = "select",
						order = 2,
						values = function() return db:GetProfiles() end,
						get = function() return db:GetCurrentProfile() end,
						set = function(info, val) db:SetProfile(val) end,
					},
					delete = {
						name = "Delete Profile",
						type = "execute",
						order = 3,
						func = function()
							db:DeleteProfile(db:GetCurrentProfile())
						end,
					},
					reset = {
						name = "Reset Profile",
						type = "execute",
						order = 4,
						func = function()
							db:ResetProfile()
						end,
					},
				}
			}
		}
	}
end

return AceDBOptions
