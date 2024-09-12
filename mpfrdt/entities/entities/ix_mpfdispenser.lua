---@diagnostic disable: duplicate-set-field
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Metropolice Ration Dispenser"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true

local RATION_ITEM = "ration_metropolice"

local DISPLAY_STANDBY = 1
local DISPLAY_CHECKING = 2
local DISPLAY_DISPENSING = 3
local DISPLAY_FREQ = 4
local DISPLAY_WAIT = 5
local DISPLAY_OFFLINE = 6
local DISPLAY_AUTH = 7
local DISPLAY_PREPARING = 8

ENT.Displays = {
	[1] = {"STANDING BY", color_white, true},
	[2] = {"CHECKING", Color(255, 200, 0)},
	[3] = {"DISPENSING", Color(0, 255, 0)},
	[4] = {"FREQ. LIMIT", Color(255, 0, 0)},
	[5] = {"WAIT", Color(255, 200, 0)},
	[6] = {"OFFLINE", Color(255, 0, 0), true},
	[7] = {"NOT AUTH.", Color(255, 0, 0)},
	[8] = {"PREPARING", Color(0, 255, 0)}
}

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Display")
	self:NetworkVar("Bool", 1, "Enabled")
end

if (SERVER) then
	function ENT:SpawnFunction(client, trace)
		local dispenser = ents.Create("ix_mpfdispenser")

		dispenser:SetPos(trace.HitPos)
		dispenser:SetAngles(trace.HitNormal:Angle())
		dispenser:Spawn()
		dispenser:Activate()
		dispenser:SetEnabled(true)

		hook.Run("SaveData")
		return dispenser
	end

	function ENT:Initialize()
		self:SetModel("models/props_junk/watermelon01.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:DrawShadow(false)
		self:SetUseType(SIMPLE_USE)
		self:SetDisplay(DISPLAY_STANDBY)
		self:SetEnabled(true)

		self.dispenser = ents.Create("prop_dynamic")
		self.dispenser:SetModel("models/props_combine/combine_dispenser.mdl")
		self.dispenser:SetPos(self:GetPos())
		self.dispenser:SetAngles(self:GetAngles())
		self.dispenser:SetParent(self)
		self.dispenser:Spawn()
		self.dispenser:Activate()
		self:DeleteOnRemove(self.dispenser)

		self.dummy = ents.Create("prop_physics")
		self.dummy:SetModel("models/weapons/w_package.mdl")
		self.dummy:SetPos(self:GetPos())
		self.dummy:SetAngles(self:GetAngles())
		self.dummy:SetMoveType(MOVETYPE_NONE)
		self.dummy:SetNotSolid(true)
		self.dummy:SetNoDraw(true)
		self.dummy:SetParent(self.dispenser, 1)
		self.dummy:Spawn()
		self.dummy:Activate()
		self:DeleteOnRemove(self.dummy)

		local physics = self.dispenser:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Sleep()

		self.canUse = true
		self.nextUseTime = CurTime()
	end

	function ENT:KeyValue(k, v)
		if (k == "OnDenyRation") then
			self:StoreOutput(k,v)
		elseif (k == "OnRationDispensed") then
			self:StoreOutput(k,v)
		elseif(k == "OnRequestRation") then
			self:StoreOutput(k,v)
		end
	end
	
	function ENT:AcceptInput(input, activator, caller, data)
		if (input ==  "DispenseRation") then
			if (!self.canUse) then return end
			local delay = tonumber(data) or 1.2
			self:SetDisplay(DISPLAY_DISPENSING)
			self:SpawnRation(function()
				self:TriggerOutput("OnRationDispensed", self)
				self.dispenser:Fire("SetAnimation", "dispense_package")
				self:EmitSound("ambient/machines/combine_terminal_idle4.wav")
			end, delay)
			return true
		end
	end

	function ENT:SpawnRation(callback, releaseDelay)
		releaseDelay = releaseDelay or 1.2

		local itemTable = ix.item.Get(RATION_ITEM)

		self.dummy:SetModel(itemTable:GetModel())
		self.dummy:SetNoDraw(false)

		if (callback) then
			callback()
		end

		timer.Simple(releaseDelay, function()
			ix.item.Spawn(RATION_ITEM, self.dummy:GetPos(), function(item, entity)
				self.dummy:SetNoDraw(true)
			end, self.dummy:GetAngles())

			-- display cooldown notice
			timer.Simple(releaseDelay, function()
				self:SetDisplay(DISPLAY_WAIT)
			end)

			-- make dispenser usable
			timer.Simple(releaseDelay + 4, function()
				self.canUse = true
				self:SetDisplay(DISPLAY_STANDBY)
			end)
		end)
	end

	function ENT:StartDispense()
		self:SetDisplay(DISPLAY_DISPENSING)
		self:SpawnRation(function()
			self:TriggerOutput("OnRationDispensed", self)
			self.dispenser:Fire("SetAnimation", "dispense_package")
			self:EmitSound("ambient/machines/combine_terminal_idle4.wav")
		end)
	end

	function ENT:DisplayError(id, length)
		id = id or 6
		length = length or 2

		self:SetDisplay(id)
		self:EmitSound("buttons/combine_button_locked.wav")
		self.canUse = false

		timer.Simple(length, function()
			self:SetDisplay(DISPLAY_STANDBY)
			self.canUse = true
		end)
	end

	function ENT:Use(client)
		if (!self.canUse or self.nextUseTime > CurTime()) then
			return
		end

		local combine = {
			[FACTION_ADMIN] = true,
			[FACTION_OTA] = true,
			[FACTION_MPF] = true
		}
		
		-- Player is combine...
		if (combine[client:Team()] == true) then
			-- Terminal is disabled...
			if (!self:GetEnabled()) then
				self:TriggerOutput("OnDenyRation", client)
				self:DisplayError(DISPLAY_OFFLINE)
			end
			
			-- Terminal is not disabled

			-- Is Overwatch?
			if (client:Team() == FACTION_OTA) then
				self:SetEnabled(!self:GetEnabled())
				self:EmitSound(self:GetEnabled() and "buttons/combine_button1.wav" or "buttons/combine_button2.wav")
				self.nextUseTime = CurTime() + 2
				return
			end

			local crc = client:GetCharacter():GetInventory():HasItem("crc")
			if (!crc) then
				self:TriggerOutput("OnDenyRation", client)
				self:DisplayError(DISPLAY_AUTH)
				return
			end

			-- Normal dispense
			self.canUse = false
			self:SetDisplay(DISPLAY_CHECKING)
			self:EmitSound("ambient/machines/combine_terminal_idle2.wav")

			timer.Simple(math.random(1.8, 2.2), function()
				if (crc:GetData("id") == nil) then
					self:TriggerOutput("OnDenyRation", client)
					self:DisplayError(DISPLAY_AUTH)
					return
				end
				if (crc:GetData("nextRationTime", 0) < os.time()) then
					self:SetDisplay(DISPLAY_PREPARING)
					self:EmitSound("ambient/machines/combine_terminal_idle3.wav")
					self:TriggerOutput("OnRequestRation", client)
					timer.Simple(10.2, function()
						self:StartDispense()
						crc:SetData("nextRationTime", os.time() + ix.config.Get("rationInterval", 1))
					end)
				else
					self:DisplayError(DISPLAY_FREQ)
				end
			end)
		else
			self:TriggerOutput("OnDenyRation", client)
			self:DisplayError(DISPLAY_AUTH)
		end
	end

	function ENT:OnRemove()
		if (!ix.shuttingDown) then
			hook.Run("SaveData")
		end
	end
else
	surface.CreateFont("ixRationDispenser", {
		font = "Default",
		size = 32,
		antialias = false
	})

	function ENT:Draw()
		local position, angles = self:GetPos(), self:GetAngles()
		local display = self:GetEnabled() and self.Displays[self:GetDisplay()] or self.Displays[DISPLAY_OFFLINE]

		angles:RotateAroundAxis(angles:Forward(), 90)
		angles:RotateAroundAxis(angles:Right(), 270)

		cam.Start3D2D(position + self:GetForward() * 7.6 + self:GetRight()*  8.5 + self:GetUp() * 3, angles, 0.1)
			render.PushFilterMin(TEXFILTER.NONE)
			render.PushFilterMag(TEXFILTER.NONE)

			surface.SetDrawColor(color_black)
			surface.DrawRect(10, 16, 153, 40)

			surface.SetDrawColor(60, 60, 60)
			surface.DrawOutlinedRect(9, 16, 155, 40)

			local alpha = display[3] and 255 or math.abs(math.cos(RealTime() * 2) * 255)
			local color = ColorAlpha(display[2], alpha)

			draw.SimpleText(display[1], "ixRationDispenser", 86, 36, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
	end
end
