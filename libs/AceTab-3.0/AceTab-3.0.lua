---@class AceTab-3.0
local AceTab = LibStub:NewLibrary("AceTab-3.0", 4)

if not AceTab then return end

function AceTab:new(frame)
	local tabs = {
		tabList = {},
		selectedTab = nil,
		frame = frame,
	}

	function tabs:AddTab(name, id)
		table.insert(self.tabList, {
			name = name,
			id = id,
		})
		return #self.tabList
	end

	function tabs:SelectTab(id)
		self.selectedTab = id
	end

	function tabs:GetSelectedTab()
		return self.selectedTab
	end

	function tabs:GetTab(index)
		return self.tabList[index]
	end

	function tabs:GetTabCount()
		return #self.tabList
	end

	return tabs
end

function AceTab:Embed(object)
	object.AddTab = self.new(object).AddTab
	object.SelectTab = self.new(object).SelectTab
	object.GetSelectedTab = self.new(object).GetSelectedTab
	return object
end

return AceTab
