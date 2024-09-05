PLUGIN.name = "Custom Currency Models"
PLUGIN.author = "Mags"
PLUGIN.description = "Changes currency model based on amount."

-- I made this to make the currency system more immersive for larger amounts in HL2RP. Why hasn't anyone done this?

function ix.currency.Spawn(pos, amount, angle)
    if (!amount or amount < 0) then
        print("[Error")
        return
    end

    local money = ents.Create("ix_money")
    money:Spawn()

-- Debugging, dont worry about this unless you know what it means.
    if (IsValid(pos) and pos:IsPlayer()) then
        pos = pos:GetItemDropPos(money)
    elseif (!isvector(pos)) then
        print("Debug: Can't create currency entity: Invalid Position")

        money:Remove()
        return
    end

    money:SetPos(pos)
    money:SetAngles(angle or angle_zero)

    -- This input will make it so that anything above 20 tokens will make it a different model. You can edit the variable.
    if (amount > 20) then
        money:SetModel("models/props_c17/BriefCase001a.mdl") -- Larger amount, so different model.
    else
        money:SetModel("models/props_lab/box01a.mdl") -- Default model for smaller amounts.
    end

    money:SetAmount(math.Round(math.abs(amount)))
    money:Activate()

    return money
end
