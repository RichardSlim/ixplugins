ITEM.name = "Heckler & Koch MP7"
ITEM.description = "Compact, matte black submachine gun chambered in 4.6x30mm. Features a folding stock for versatility in close-quarters combat, combining tactical design with lethal firepower."
ITEM.model = "models/weapons/w_smg1.mdl"
ITEM.class = "ix_mp7smg"
ITEM.weaponCategory = "primary"
ITEM.width = 3
ITEM.height = 2
ITEM.weight = 3.4
ITEM.outfitCategory = "primary"
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(-9.42, 350.45, 155.42),
	ang = Angle(24, 271.23, 0),
	fov = 3.17
}

function ITEM:PopulateTooltip(tooltip)
    local warning = tooltip:AddRow("warning")
	warning:SetTextColor(Color(255, 50, 5, 225))
	warning:SetText("This item is RED level contraband")
	warning:SetFont("DermaDefault")
	warning:SetExpensiveShadow(1)
	warning:SizeToContents()
end

ITEM.pacData = {
	[1] = {
		["children"] = {
			[1] = {
				["children"] = {
				},
				["self"] = {
					["Angles"] = Angle(200, 0, 180),
					["Position"] = Vector(-1, -4, -4),
					["UniqueID"] = "42498116281111111",
					["Size"] = 1,
					["Bone"] = "spine 2",
					["Model"] = "models/weapons/w_smg1.mdl",
					["ClassName"] = "model",
				},
			},
		},
		["self"] = {
			["ClassName"] = "group",
			["UniqueID"] = "9071598171111111",
			["EditorExpand"] = true,
		},
	},
}