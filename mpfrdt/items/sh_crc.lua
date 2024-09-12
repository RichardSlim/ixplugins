
ITEM.name = "Combine Remuneration Card"
ITEM.model = Model("models/sky/combinecard2.mdl")
ITEM.description = "A combine card with ID #%s, assigned to %s, used to dispatching credits and rations to metropolice."

---@diagnostic disable-next-line: duplicate-set-field
function ITEM:GetDescription()
	if (self:GetData("id") == nil) then return "A combine card with empty ID. It is ready to be assigned to a unit." end
    return string.format(self.description, self:GetData("id", "00000"), self:GetData("name", "nobody"))
end

---@diagnostic disable-next-line: duplicate-set-field
function ITEM:GetName()
    if (self:GetData("id") == nil) then
        return "Unregistered Combine Remuneration Card"
    end
	return "Combine Remuneration Card"
end

ITEM.functions.Register = {
	name = "Register Self",
	OnRun = function(item)
        local client = item.player
        local character = client:GetCharacter()
        local id = character:GetData("cid") or Schema:ZeroNumber(math.random(1, 99999), 5)
        character:SetData("cid", id)
        character:SetData("crc", id)
        item:SetData("name", character:GetName())
		item:SetData("id", id)
		client:Notify("Assigned CRC card.")
		return false
	end,
	OnCanRun = function(item)
        local client = item.player
        if (!client:IsCombine()) then return false end
		if (item:GetData("id") ~= nil) then return false end
	end
}

ITEM.functions.ClearData = {
	name = "(ADMIN) Remove card data and clear own crc ID.",
	icon = "icon16/wrench.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		character:SetData("crc", nil)
		item:SetData("id", nil)
		item:SetData("name", nil)
		client:Notify("Data cleared.")
		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		if (!client:IsSuperAdmin()) then return false end
		if (character:GetData("crc") == nil) then return false end
	end
}

ITEM.functions.ClearRationTime = {
	name = "(ADMIN) Reset ration time counter",
	icon = "icon16/wrench.png",
	OnRun = function (item)
		local client = item.player
		item:SetData("nextRationTime", CurTime())
		client:Notify("Timer reset.")
		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		return client:IsSuperAdmin()
	end
}