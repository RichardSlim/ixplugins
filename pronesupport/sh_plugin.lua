PLUGIN.name = "Prone Support"
PLUGIN.author = "Mags"
PLUGIN.description = "Adds prone functionality support for ixhl2rp."

if SERVER then
    function PLUGIN:PostPlayerDeath(ply)
        if ply:IsProne() then
            prone.Exit(ply)
        end
    end
end

function PLUGIN:CanPlayerRagdoll(ply)
    if ply:IsProne() then
        return false
    end
end