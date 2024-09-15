PLUGIN.name = "Noclip Flag" 
PLUGIN.author = "Mags"
PLUGIN.description = "Allows admins to give players noclip access through a specific flag."

-- This adds the "N" flag for noclip.
ix.flag.Add("N", "Grants the player noclip permission.", function(client, bGiven)
    -- when the flag is given or taken away.
    if bGiven then
        print(client:Name() .. " was given noclip access.")
        client:ChatPrint("You have been granted noclip access.")
    else
        print(client:Name() .. " had their noclip access removed.")
        client:ChatPrint("Your noclip access has been revoked.")
    end
end)

-- Hook for access.
function PLUGIN:PlayerNoClip(client)
    -- Check if the player has the "N" flag
    if client:GetCharacter() and client:GetCharacter():HasFlags("N") then
        return true -- Allow noclip
    else
        return false -- Deny noclip without printing a message
    end
end