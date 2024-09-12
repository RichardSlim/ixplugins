function PLUGIN:SaveData()
    local data = {}

    for _, v in ipairs(ents.FindByClass("ix_mpfdispenser")) do
        data[#data + 1] = { v:GetPos(), v:GetAngles(), v:GetEnabled(), v:MapCreationID() }
    end
    
    self:SetData(data)
end

function PLUGIN:LoadData()
    local data = self:GetData({}) or {}

    for k,v in ipairs(data) do
        local mapid = v[4] or -1
        if (mapid > -1) then
            -- This entity was created by the map. We don't need to spawn a new one.
            local dispenser = ents.GetMapCreatedEntity(mapid)
            if (dispenser) then
                dispenser:SetEnabled(v[3])
            end
        else
            local dispenser = ents.Create("ix_mpfdispenser")
            dispenser:SetPos(v[1])
            dispenser:SetAngles(v[2])
            dispenser:Spawn()
            dispenser:SetEnabled(v[3])
        end
    end
end

function PLUGIN:GiveCRC(character)
    local inv = character:GetInventory()
    local id = character:GetData("cid") or Schema:ZeroNumber(math.random(1, 99999), 5)
    character:SetData("cid", id)
    character:SetData("crc", id)
    local crc = inv:HasItem("crc")
    if (crc) then
        crc:SetData("id", id)
        crc:SetName("name", character:GetName())
    end

    local card = inv:Add("crc", 1, {
        name = character:GetName(),
        id = id
    })
end

---@diagnostic disable-next-line: duplicate-set-field
function PLUGIN:OnCharacterCreated(client, character)
    if (client:Team() == FACTION_MPF) then
        self:GiveCRC(character)
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function PLUGIN:CharacterLoaded(character)
    local client = character:GetPlayer()
    if (client:Team() != FACTION_MPF) then
        return
    end

    if (character:GetData("crc") == nil) then
        self:GiveCRC(character)
    end
end